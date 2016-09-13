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

  desc 'Mobile | Remove old app history versions except the latest build version by each release version'
  task remove_old: :environment do
    apps = App.all
    apps_count = apps.count
    apps.each_with_index do |app, index|
      puts "[#{index + 1}/#{apps_count}] #{app.id} - #{app.device_type} - #{app.name} - #{Time.now.strftime('%Y%m%d%H%M')}"

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
