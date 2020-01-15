# frozen_string_literal: true

require_relative 'config'

module Backup
  class Upload
    include Backup::Config

    def dump
      prepare
      print "Dumping uploaded apps from #{apps_stored_path} ... "
      Dir.glob("#{apps_stored_path}/*").each do |app_path|
        Dir.glob("#{app_path}/*").each do |release_path|
          relative_path = release_path.gsub(apps_stored_path, '')
          app_dirname, release_dirname = relative_path[1..-1].split('/')
          backup_path = File.join(apps_backup_path, app_dirname)

          print " * #{app_dirname}/#{release_dirname} ... "
          FileUtils.mkdir_p(backup_path)
          FileUtils.cp_r(release_path, backup_path)
          print '[DONE]'
          puts ''
        end
      end

      puts '[DONE]'
    end

    def restore
      puts "Restore uploaded apps to #{apps_stored_path} ... "
      unless File.exist?(apps_backup_path)
        puts 'No uploaded apps found'
        exit 1
      end

      if File.exist?(apps_stored_path)
        backup_apps_path = File.join(app_uploads_path, "apps.old.#{Time.zone.now.strftime('%Y%m%d%H%M%S')}")

        FileUtils.mv(apps_stored_path, backup_apps_path)
        FileUtils.mkdir_p(apps_stored_path)
      end

      Dir.glob("#{apps_backup_path}/*").each do |app_path|
        Dir.glob("#{app_path}/*").each do |release_path|
          relative_path = release_path.gsub(apps_backup_path, '')
          app_dirname, release_dirname = relative_path[1..-1].split('/')
          restore_path = File.join(apps_stored_path, app_dirname)

          print " * #{app_dirname}/#{release_dirname} ... "
          FileUtils.mkdir_p(restore_path) unless File.exist?(restore_path)
          FileUtils.mv(release_path, restore_path)
          puts '[DONE]'
        end
      end
    end

    protected

    def prepare
      FileUtils.rm_rf(apps_backup_path)
      # Fail if somebody raced to create backup_repos_path before us
      FileUtils.mkdir_p(apps_backup_path, mode: 0_700)
    end
  end
end
