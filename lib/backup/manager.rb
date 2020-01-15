# frozen_string_literal: true

require_relative 'config'
require_relative '../setting'
require 'yaml'

module Backup
  class Manager
    include Backup::Config

    ZIP_FILE = 'zealot_backup.tar'.freeze
    INFO_FILE = 'backup_information.yml'.freeze

    FOLDERS_TO_BACKUP = %w[apps db]

    def pack
      # Make sure there is a connection
      ActiveRecord::Base.connection.reconnect!

      # saving additional informations
      s = {}
      s[:rails_env]           = Rails.env.to_s
      s[:app_version]         = Setting.version
      s[:db_adapter]          = db_config[:adapter]
      s[:db_host]             = db_config[:host]
      s[:db_port]             = db_config[:port] || 3306
      s[:db_database]         = db_config[:database]
      s[:db_user]             = db_config[:username]
      s[:db_migrator_version] = ActiveRecord::Migrator.current_version
      s[:backup_created_at]   = Time.zone.now.strftime('%Y%m%d%H%M%S')

      tar_file = tarchive_file(s[:backup_created_at])
      Dir.chdir(backup_path) do
        File.open(File.join(backup_path, INFO_FILE), 'w+') do |file|
          file << s.to_yaml.gsub(/^---\n/, '')
        end

        print "Creating backup archive: #{File.join(backup_path, tar_file)} ... "
        tar_system_options = { out: [tar_file, 'w', 0_600] }
        unless Kernel.system('tar', '-cf', '-', *backup_contents, tar_system_options)
          puts "creating archive #{tar_file} failed"
          abort 'Backup failed'
        end

        puts '[DONE]'
      end
    end

    def cleanup
      print 'Deleting tmp directories ... '

      backup_contents.each do |dir|
        next unless File.exist?(File.join(backup_path, dir))

        unless FileUtils.rm_rf(File.join(backup_path, dir))
          puts "deleting tmp directory '#{dir}' failed"
          abort 'Backup failed'
        end
      end

      puts '[DONE]'
    end

    def remove_old
      print 'Deleting old backups ... '
      if keep_max_time.positive?
        removed = 0

        Dir.chdir(backup_path) do
          file_list = Dir.glob(tarchive_file('*'))
          file_list.map! { |f| $1.to_i if f =~ /(\d+)_zealot_backup.tar/ }
          file_list.sort.each do |timestamp|
            if Time.at(timestamp) < (Time.zone.now - keep_max_time)
              if Kernel.system(*%W(rm #{tarchive_file(timestamp)}))
                removed += 1
              end
            end
          end
        end
      else
        puts 'skipping'
      end

      puts '[DONE]'
    end

    def unpack
      Dir.chdir(backup_path)

      puts 'No backups found' if backups_list.count.zero?

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

      print "Unpacking backup ... #{tar_file} "
      unless Kernel.system(*%W(tar -xf #{tar_file}))
        puts 'unpacking backup failed'
        exit 1
      else
        puts '[DONE]'
      end

      if backup_information[:app_version] != Setting.version
        puts 'Zealot version mismatch:'
        puts "  Your current Zealot version (#{Setting.version}) differs from the Zealot version in the backup!"
        puts '  Please switch to the following version and try again:'
        puts "  version: #{backup_information[:app_version]}"
        puts
        puts "Hint: git checkout #{backup_information[:app_version]}"
        exit 1
      end
    end

    def backups_list
      Dir.chdir(backup_path)
      @backups_list ||= Dir.glob("#{tarchive_file('*')}*")
    end

    private

    def tarchive_file(prefix)
      "#{prefix}_#{ZIP_FILE}"
    end

    def backup_contents
      FOLDERS_TO_BACKUP.push(INFO_FILE)
    end

    def backup_information
      @backup_information ||= YAML.load_file(INFO_FILE)
    end
  end
end
