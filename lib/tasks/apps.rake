namespace :apps do
  desc '更新 app key'
  task update_app_key: :environment do
    App.all.each do |app|
      app.key = Digest::MD5.hexdigest(SecureRandom.uuid + app.identifier)
      app.save!
    end
  end

  desc 'Cleanup app history versions'
  task clean: :environment do
    App.all.each_with_index do |app, index|
      puts "[#{index + 1}] #{app.id} - #{app.name}"

      app_branch_cache_key = "app_#{app.id}_branches"
      Rails.cache.delete(app_branch_cache_key)
      app.branches.each do |branch|
        release_versions = app.releases
                              .where(branch: branch.name)
                              .group(:release_version)
                              .map(&:release_version)

        latest_version = release_versions.max

        puts " => BRANCH: #{branch.name}"
        puts " -> latest_version:\t#{latest_version}"
        puts " -> avaiable versions:\t#{release_versions.to_a.join(', ')}"
        clean_vesions = release_versions.delete_if { |v| v == latest_version }

        next if clean_vesions.empty?

        puts " -> clean versions:\t#{clean_vesions.join(', ')}"
        puts ' -> cleaning'

        clean_vesions.each do |version|
          releases = Release.where(app: app, branch: branch.name, release_version: version)
          print "    * #{version} (#{releases.size})"
          # keep_count = ENV["KEEP"].to_i || 1
          if releases.size > 1
            build_versions = releases.map(&:build_version)
            latest_build_version = build_versions.max

            puts ' [CLEAN & KEEP LATEST]'
            if build_versions.select { |v| v == latest_build_version }.size == build_versions.size
              auto_versions = releases.map(&:version)
              latest_build_release = Release.where(app: app, branch: branch.name, release_version: version).last
              puts "      avaiable:\t#{auto_versions.join(', ')}"
              puts "      latest:\t#{latest_build_release.version}"
              releases.each do |r|
                if r.id != latest_build_release.id
                  r.remove_file
                  r.remove_icon
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
                  r.destroy
                end
              end
            end
          else
            puts ' [SKIP]'
          end
        end

        Rails.cache.delete(app_branch_cache_key)
      end
    end
  end

  desc 'List all app details'
  task list: :environment do
    App.all.each do |app|
      puts "#{app.id} - #{app.device_type} - #{app.name}"
      app.release_versions.each do |version|
        puts "-> #{version}"
      end
    end
  end
end
