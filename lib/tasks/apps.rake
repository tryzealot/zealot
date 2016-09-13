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
    App.all.each_with_index do |app, index|
      puts "[#{index + 1}] #{app.id} - #{app.name} - #{Time.now.strftime('%Y%m%d%H%M')}"

      release_versions = app.release_versions
      latest_version = release_versions.max

      puts " -> latest_version:\t#{latest_version}"
      puts " -> avaiable versions:\t#{release_versions.to_a.join(', ')}"
      clean_vesions = release_versions.delete_if { |v| v == latest_version }

      next if clean_vesions.empty?

      puts " -> clean versions:\t#{clean_vesions.join(', ')}"
      puts ' -> cleaning'

      clean_vesions.each do |version|
        releases = Release.where(app: app, release_version: version)
        print "    * #{version} (#{releases.size})"
        # keep_count = ENV["KEEP"].to_i || 1
        if releases.size > 1
          build_versions = releases.map(&:build_version)
          latest_build_version = build_versions.max

          puts ' [CLEAN & KEEP LATEST]'
          if build_versions.select { |v| v == latest_build_version }.size == build_versions.size
            # 处理 build version 一致采用 version 来解决 build version 保留最新
            auto_versions = releases.map(&:version)
            latest_build_release = Release.where(app: app, release_version: version).last
            puts "      avaiable:\t#{auto_versions.join(', ')}"
            puts "      latest:\t#{latest_build_release.version}"
            releases.each do |r|
              if r.id != latest_build_release.id
                r.remove_file
                r.remove_icon
                FileUtils.rm_rf(File.join(Rails.root, 'public', 'uploads', 'apps', "a#{app.id}", "r#{r.id}"))
                r.destroy
              end
            end
          else
            puts "      avaiable:\t#{build_versions.join(', ')}"
            puts "      latest:\t#{latest_build_version}"
            releases.each do |r|
              if r.build_version != latest_build_version
                r.remove_file
                r.remove_icon
                FileUtils.rm_rf(File.join(Rails.root, 'public', 'uploads', 'apps', "a#{app.id}", "r#{r.id}"))
                r.destroy
              end
            end
          end
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
