namespace :apps do
  desc "Cleanup app history versions"
  task :clean => :environment do
    App.all.each_with_index do |app, index|
      puts "[#{index+1}] #{app.id} - #{app.name}"
      release_versions = app.releases.group(:release_version).map { |m| m.release_version }
      latest_version = release_versions.max #max_version(versions)

      puts " -> latest_version:\t#{latest_version}"
      puts " -> avaiable versions:\t#{release_versions.to_a.join(", ")}"
      clean_vesions = release_versions.delete_if { |v| v == latest_version }
      puts " -> clean versions:\t#{clean_vesions.join(", ")}"
      puts " -> cleaning"

      clean_vesions.each do |version|
        releases = Release.where(app: app, release_version: version)
        print "    * #{version} (#{releases.size})"
        if releases.size > 1
          build_versions = releases.map { |m| m.build_version }
          latest_build_version = build_versions.max
          if ENV['DELETE'.freeze].to_i == 1
            releases.each do |r|
              r.destroy if r.build_version != latest_build_version
            end
            puts " [CLEAN & KEEP LATEST]"
          else
            puts " [PREVIEW]"
          end

          puts "      avaiable:\t#{build_versions.join(", ")}"
          puts "      latest:\t#{latest_build_version}"
        else
          puts " [SKIP]"
        end
      end
    end
  end

  desc "List all app details"
  task :list => :environment do
    App.all.each do |app|
      puts "#{app.id} - #{app.slug} - #{app.name}"
      app.branches.each do |branch|
        puts " -> #{branch.name} - #{branch.count}"
      end
    end
  end
end