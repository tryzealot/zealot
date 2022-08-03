# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

# Portions of this software are licensed as follows:

# * All content residing under the "doc/" directory of this repository is licensed under "Creative Commons: CC BY-SA 4.0 license".
# * All content that resides under the "ee/" directory of this repository, if that directory exists, is licensed under the license defined in "ee/LICENSE".
# * All client-side JavaScript (when served directly or after being compiled, arranged, augmented, or combined), is licensed under the "MIT Expat" license.
# * All third party components incorporated into the GitLab Software are licensed under the original license provided by the owner of the applicable component.
# * Content outside of the above mentioned directories or restrictions above is available under the "MIT Expat" license as defined below.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Zealot::Backup
  class Manager
    include Zealot::Backup::Helper

    class Error < StandardError; end

    ARCHIVES_TO_BACKUP = %w[uploads.tar.gz]
    FOLDERS_TO_BACKUP = %w[db]
    FILE_NAME_SUFFIX = '_zealot_backup.tar'
    FILE_REGEX = /^(\d{10})?(_*)(\d{4}_\d{2}_\d{2}|\d{8}-\d{4})(_\d+\.\d+\.\d+((-|\.)(beta\d|pre\d|rc\d)?)?)?([_-]development)?_zealot_backup\.tar$/

    attr_reader :path, :logger

    def initialize(path = nil, logger = nil)
      @path = path || backup_path
      @logger = logger || Logger.new(STDOUT)
    end

    def write_info
      # Make sure there is a connection
      ActiveRecord::Base.connection.reconnect!

      File.open(backup_information_file, "w") do |file|
        file << backup_information.to_yaml.gsub(/^---\n/, '')
      end
    end

    def pack
      Dir.chdir(path) do
        # create archive
        logger.debug "Creating backup archive: #{tar_file} ... "
        # Set file permissions on open to prevent chmod races.
        tar_system_options = { out: [tar_file, 'w', 0640] }
        unless system(tar, '-cf', '-', *backup_contents, tar_system_options)
          raise Zealot::Backup::Manager::Error, "Backup failed: creating archive #{tar_file} failed"
        end
      end
    end

    def cleanup
      logger.debug 'Deleting tmp directories ... '

      backup_contents.each do |dir|
        next unless File.exist?(File.join(path, dir))

        unless FileUtils.rm_rf(File.join(path, dir))
          raise Zealot::Backup::Manager::Error, "Backup failed: deleting tmp directory '#{dir}' failed"
        end
      end
    end

    def remove_old
      logger.debug 'Deleting old backups ... '
      keep_time = Setting.backup[:keep_time]

      if keep_time > 0
        removed = 0

        Dir.chdir(path) do
          backup_file_list.each do |file|
            # For compatibility, there are 4 names the backups can have:
            # - 1590060675_2020_05_21_zealot_backup.tar
            # - 1590060675_2020_05_21_development_zealot_backup.tar
            # - 1590060675_2020_05_21_4.0.0-beta4_zealot_backup.tar
            # - 1590060675_2020_05_21_4.0.0-beta4-development_zealot_backup.tar
            # - 20220803-2300_4.5.0_zealot_backup.tar
            next unless file =~ FILE_REGEX

            timestamp = $1.to_i

            if Time.at(timestamp) < (Time.now - keep_time)
              begin
                FileUtils.rm(file)
                removed += 1
              rescue => e
                logger.debug "Deleting #{file} failed: #{e.message}"
              end
            end
          end
        end

        logger.debug "#{removed} old backup removed"
      else
        logger.debug "keep backup forever"
      end
    end

    def unpack
      FileUtils.mkdir_p(path)

      Dir.chdir(path) do
        # check for existing backups in the backup dir
        if backup_file_list.empty?
          logger.debug "No backups found in #{path}"
          logger.debug "Please make sure that file name ends with #{FILE_NAME_SUFFIX}"
          exit 1
        elsif backup_file_list.many? && ENV["BACKUP"].nil?
          logger.debug 'Found more than one backup:'
          # print list of available backups
          logger.debug " " + available_timestamps.join("\n ")
          logger.debug 'Please specify which one you want to restore:'
          logger.debug 'rake gitlab:backup:restore BACKUP=timestamp_of_backup'
          exit 1
        end

        tar_file = backup_file_list.first
        unless File.exist?(tar_file)
          logger.debug "The backup file #{tar_file} does not exist!"
          exit 1
        end

        logger.debug 'Unpacking backup ... ', false
        if system(*%W(tar -xf #{tar_file}))
          return true
        else
          logger.error 'Unpacking backup failed'
          exit 1
        end
      end
    end

    def verify_backup_version
      Dir.chdir(path) do
        # restoring mismatching backups can lead to unexpected problems
        current_version = Setting.version
        if settings[:zealot_version] != current_version
          logger.puts(<<~HEREDOC.color(:red))
            Zealot version mismatch:
              Your current Zealot version (#{current_version}) differs from the Zealot version in the backup!
              Please switch to the following version and try again:
              version: #{settings[:zealot_version]}
          HEREDOC
          logger.puts
          logger.puts "Hint:"
          logger.puts "  1. git checkout v#{settings[:zealot_version]}"
          logger.puts "  2. docker pull tryzealot/zealot:#{settings[:zealot_version]}"
          exit 1
        end
      end
    end

    private

    def backup_information
      @backup_information ||= {
        zealot_version: Setting.version,
        backup_created_at: Time.now,
        db_version: ActiveRecord::Migrator.current_version.to_s,
        tar_version: tar_version,
        vcs_ref: Setting.vcs_ref || false,
        docker_tag: ENV['DOCKER_TAG'] || false
      }
    end

    def backup_file_list
      @backup_file_list ||= Dir.glob("*#{FILE_NAME_SUFFIX}")
    end

    def backup_contents
      precheck_content(ARCHIVES_TO_BACKUP) + precheck_content(FOLDERS_TO_BACKUP) + ['backup_information.yml']
    end

    def precheck_content(source)
      source.each_with_object([]) do |item, obj|
        obj << item if File.exist?(File.join(path, item))
      end
    end

    def settings
      @settings ||= YAML.load_file('backup_information.yml')
    end

    def tar_file
      @tar_file ||= if ENV['BACKUP'].present?
                      File.basename(ENV['BACKUP']) + FILE_NAME_SUFFIX
                    else
                      timestamp = backup_information[:backup_created_at].strftime('%Y%m%d-%H%M')
                      zealot_version = backup_information[:zealot_version]
                      "#{timestamp}_#{zealot_version}#{FILE_NAME_SUFFIX}"
                    end
    end

    def tar_version
      @tar_version ||= `#{tar} --version`.dup
        .force_encoding('locale')
        .split("\n")
        .first
    end

    def backup_information_file
      @backup_information_file ||= File.join(path, 'backup_information.yml')
    end
  end
end