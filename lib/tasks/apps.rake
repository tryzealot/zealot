require 'fileutils'

namespace :apps do
  desc 'Mobile | Generate app key'
  task update_app_key: :environment do
    App.all.each do |app|
      next unless app.key.blank?
      app.key = Digest::MD5.hexdigest(SecureRandom.uuid + app.identifier)
      app.save!
    end
  end

  desc 'Mobile | Reverse remove directory if release is not exist of app'
  task cleanup: :environment do
    store_path = File.join(Rails.root, 'public', 'uploads')
    Dir.glob("#{store_path}/apps/*").each do |app_path|
      Dir.glob("#{app_path}/*").each do |release_path|
        print release_path
        release_id = File.basename(release_path)[1..-1]
        begin
          release = Release.find(release_id)
        rescue
          print ' removed'
          FileUtils.rm_rf release_path
        end
        puts ''
      end
    end

    `find #{File.join(store_path, 'apps')} -type d -depth -empty -exec rmdir "{}" \;`
  end

  desc 'Mobile | Migrate old app path to new directory structure'
  task migrate_upload_path: :environment do
    store_path = File.join(Rails.root, 'public', 'uploads')
    Dir.glob("#{store_path}/apps/*").each do |app_path|
      Dir.glob("#{app_path}/*").each do |release_path|
        puts release_path
        ['binary', 'icons'].each do |dir_name|
          FileUtils.mkdir_p(File.join(release_path, dir_name))
        end
        new_path = File.join(release_path, 'binary')
        FileUtils.mv Dir.glob(File.join(release_path, "*.ipa")), new_path
        FileUtils.mv Dir.glob(File.join(release_path, "*.apk")), new_path
      end
    end

    Dir.glob("#{store_path}/release/icon/*").each do |release_path|
      begin
        release = Release.find(File.basename(release_path).to_i)
        if release
          new_path = File.join(store_path, 'apps', "a#{release.app.id}", "r#{release.id}", 'icons')
          if Dir.exist?new_path
            FileUtils.cp_r Dir.glob("#{release_path}/*"), new_path
          else
            raise 'Not found path'
          end
        else
          FileUtils.rm_rf release_path
        end
      rescue
        FileUtils.rm_rf release_path
        next
      end
    end
  end

  desc 'Mobile | Remove old app history versions except the latest build version by each release version'
  task remove_old: :environment do
    apps = App.all
    apps_count = apps.count
    apps.each_with_index do |app, index|
      puts "[#{index + 1}/#{apps_count}] #{app.id} - #{app.device_type} - #{app.name} - #{Time.zone.now.strftime('%Y%m%d%H%M')}"

      release_versions = app.release_versions
      latest_version = release_versions.max

      puts " -> latest RELEASE version:\t#{latest_version}"
      puts " -> avaiable RELEASE versions:\t#{release_versions.to_a.join(', ')}"
      history_versions = release_versions.delete_if { |v| v == latest_version }

      next if history_versions.empty?

      puts " -> history RELEASE versions:\t#{history_versions.join(', ')}"
      puts ' -> remove old versions with each history release version'

      history_versions.each do |version|
        releases = Release.where(app: app, release_version: version)
        print "    * #{version} (#{releases.size})"

        if releases.size > 1
          build_versions = releases.map(&:version)
          latest_build_version = build_versions.max

          puts ' [CLEAN & KEEP LATEST]'
          puts "      avaiable: #{build_versions.join(', ')}"
          puts "      latest: #{latest_build_version}"
          print "      removed: "
          releases.each do |r|
            next if r.version == latest_build_version
            r.remove_file
            r.remove_icon
            FileUtils.rm_rf(File.join(Rails.root, 'public', 'uploads', 'apps', "a#{app.id}", "r#{r.id}"))
            r.destroy
            print "#{r.version}, "
          end
          puts ""
        else
          puts ' [SKIP]'
        end
      end
    end

    Rake::Task['apps:cleanup'].invoke
  end

  desc 'Mobile | List all app details'
  task list: :environment do
    App.all.each do |app|
      puts "#{app.id} - #{app.device_type} - #{app.name}"
      app.release_versions.each do |version|
        puts "-> #{version}"
      end
    end
  end
end
