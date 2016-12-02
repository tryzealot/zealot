require 'yaml'

module Backup
  class Manager
    module Config

      def backup_path
        File.join(Rails.root, 'tmp', 'backups')
      end

      def db_config
        YAML.load_file(File.join(Rails.root, 'config', 'database.yml'))[Rails.env]
      end

      def db_backup_path
        File.join(backup_path, 'db')
      end

      def db_backup_file_path
        File.join(db_backup_path, 'database.sql.gz')
      end

      def app_uploads_path
        File.join(Rails.root, 'public', 'uploads')
      end

      def apps_stored_path
        File.join(app_uploads_path, 'apps')
      end

      def apps_backup_path
        File.join(backup_path, 'apps')
      end

      def keep_max_time
        15
      end
    end

    include Config

    FOLDERS_TO_BACKUP = %w[apps db]

    def pack
      # Make sure there is a connection
      ActiveRecord::Base.connection.reconnect!

      # saving additional informations
      s = {}
      s[:rails_env]           = Rails.env.to_s
      s[:app_version]         = Mobile.version
      s[:db_adapter]          = db_config['adapter']
      s[:db_host]             = db_config['host']
      s[:db_port]             = db_config['port'] || 3306
      s[:db_database]         = db_config['database']
      s[:db_user]             = db_config['username']
      s[:db_migrator_version] = "#{ActiveRecord::Migrator.current_version}"
      s[:backup_created_at]   = Time.zone.now.strftime('%Y%m%d%H%M%S')

      tar_file = "#{s[:backup_created_at]}_mobile_backup.tar"
      Dir.chdir(backup_path) do
        File.open("#{backup_path}/backup_information.yml", 'w+') do |file|
          file << s.to_yaml.gsub(/^---\n/,'')
        end

        puts "Creating backup archive: #{tar_file} ... "
        tar_system_options = {out: [tar_file, 'w', 0600]}
        unless Kernel.system('tar', '-cf', '-', *backup_contents, tar_system_options)
          puts "creating archive #{tar_file} failed"
          abort 'Backup failed'
        end
      end
    end

    def cleanup
      puts 'Deleting tmp directories ... '

      backup_contents.each do |dir|
        next unless File.exist?(File.join(backup_path, dir))

        unless FileUtils.rm_rf(File.join(backup_path, dir))
          puts "deleting tmp directory '#{dir}' failed"
          abort 'Backup failed'
        end
      end
    end

    def remove_old
      puts 'Deleting old backups ... '
      if keep_max_time > 0
        removed = 0

        Dir.chdir(backup_path) do
          file_list = Dir.glob('*_mobile_backup.tar')
          file_list.map! { |f| $1.to_i if f =~ /(\d+)_mobile_backup.tar/ }
          file_list.sort.each do |timestamp|
            if Time.at(timestamp) < (Time.zone.now - keep_max_time)
              if Kernel.system(*%W(rm #{timestamp}_mobile_backup.tar))
                removed += 1
              end
            end
          end
        end
      else
        puts 'skipping'
      end
    end

    def unpack
      Dir.chdir(backup_path)

      puts 'No backups found' if backups_list.count == 0

      if backups_list.count > 1 && ENV['BACKUP'].nil?
        puts 'Found more than one backup, please specify which one you want to restore:'
        puts 'rake mobile:restore BACKUP=file_name_of_backup'
        exit 1
      end

      tar_file = ENV['BACKUP'].nil? ? backups_list.first : ENV['BACKUP']
      unless File.exist?(tar_file)
        puts 'The specified backup doesn\'t exist!'
        exit 1
      end

      print "Unpacking backup ... #{tar_file}"
      unless Kernel.system(*%W(tar -xf #{tar_file}))
        puts 'unpacking backup failed'
        exit 1
      else
        puts '[DONE]'
      end

      if backup_information[:app_version] != Mobile.version
        puts "Mobile version mismatch:"
        puts "  Your current Mobile version (#{Mobile.version}) differs from the Mobile version in the backup!"
        puts "  Please switch to the following version and try again:"
        puts "  version: #{backup_information[:app_version]}"
        puts
        puts "Hint: git checkout #{backup_information[:app_version]}"
        exit 1
      end
    end

    def backups_list
      Dir.chdir(backup_path)
      @file_list ||= Dir.glob('*_mobile_backup.tar*')
    end

    private

    def backup_contents
      FOLDERS_TO_BACKUP.push('backup_information.yml')
    end

    def backup_information
      @settings ||= YAML.load_file("backup_information.yml")
    end
  end
end