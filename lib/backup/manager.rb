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

      def db_file_name
        File.join(db_backup_path, 'database.sql.gz')
      end

      def app_store_path
        File.join(Rails.root, 'public', 'uploads', 'apps')
      end

      def uploads_backup_path
        File.join(backup_path, 'uploads')
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
      s[:db_adapter]         = db_config['adapter']
      s[:db_version]         = "#{ActiveRecord::Migrator.current_version}"
      s[:db_host]            = db_config['host']
      s[:db_port]            = db_config['port'] || 3306
      s[:db_database]        = db_config['database']
      s[:db_user]            = db_config['username']
      s[:rails_env]          = Rails.env.to_s
      s[:backup_created_at]  = Time.zone.now.strftime('%Y%m%d%H%M')

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

    private

    def backup_contents
      FOLDERS_TO_BACKUP.push('backup_information.yml')
    end
  end
end