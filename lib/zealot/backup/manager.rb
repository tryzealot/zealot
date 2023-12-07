# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

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
  class Error < StandardError; end
  class DatabaseError < Error; end
  class UploadsError < Error; end
  class DumpDatabaseError < DatabaseError; end
  class RestoreDatabaseError < DatabaseError; end

  class Manager
    include Zealot::Backup::Helper

    TEMPDIR_PREFIX = 'zealot-backup'
    DEFAULT_BACKUP_PATH = 'public/backup'

    ARCHIVES_TO_BACKUP = [ Zealot::Backup::Uploads::FILENAME ]
    FOLDERS_TO_BACKUP = [ Zealot::Backup::Database::FILENAME ]
    FILENAME_SUFFIX = '_zealot_backup.tar'

    # For compatibility, there are 5 names the backups can have:
    # - 1590060675_2020_05_21_zealot_backup.tar
    # - 1590060675_2020_05_21_development_zealot_backup.tar
    # - 1590060675_2020_05_21_4.0.0-beta4_zealot_backup.tar
    # - 1590060675_2020_05_21_4.0.0-beta4-development_zealot_backup.tar
    # - 1590060675_20220809-1122_4.0.0-beta4-development_zealot_backup.tar
    FILE_REGEX = /^(\d{10})?(_*)(\d{4}_\d{2}_\d{2}|\d{8}-\d{4})(_\d+\.\d+\.\d+((-|\.)(beta\d|pre\d|rc\d)?)?)?([_-]development)?_zealot_backup\.tar$/

    attr_reader :backup_path, :logger

    def initialize(key, logger = Rails.logger)
      @backup_path = Rails.root.join(backup_root_path, key)
      @logger = logger
    end

    def dump_all(app_ids: :all, force: false)
      precheck(force)
      dump_database
      dump_uploads(app_ids: app_ids)
      write_info
      pack
    ensure
      cleanup
    end

    # Precheck backup file not exists
    def precheck(force)
      if !force && File.file?(tar_file)
        key = File.basename(@backup_path)
        file = File.basename(tar_file)
        raise Zealot::Backup::Error, "`#{key}` backup file was existed: #{file}, set force: true to overwrite."
      end
    end

    # dump database into archive file
    def dump_database
      Zealot::Backup::Database.dump(self)
    end

    # dump uploads of given app into archive file
    def dump_uploads(app_ids: :all)
      Zealot::Backup::Uploads.dump(self, app_ids: app_ids)
    end

    # generate a backup information file
    def write_info
      # Make sure there is a connection
      ActiveRecord::Base.connection.reconnect!

      File.open(backup_information_file, "w") do |file|
        file << backup_information.to_yaml.gsub(/^---\n/, '')
      end
    end

    # pack all files above into the final backup file
    def pack
      FileUtils.mkdir_p(@backup_path)
      Dir.chdir(tmpdir) do
        # create archive
        logger.debug "Creating backup archive: #{File.basename(tar_file)} ... "
        # Set file permissions on open to prevent chmod races.
        tar_system_options = { out: [tar_file, 'w', 0640] }
        unless system(tar, '-cf', '-', *backup_contents, tar_system_options)
          raise Zealot::Backup::Error, "Backup failed: creating archive #{tar_file} failed"
        end
      end
    end

    def remove_old(max_keeps = nil)
      logger.debug 'Deleting old backups ... '
      Dir.chdir(backup_path) do
        max_keeps ||= Setting.backup[:max_keeps]
        backup_file_count = backup_file_list.size

        return if max_keeps <= 0
        return if backup_file_count.zero? # never happend
        return if backup_file_count <= max_keeps

        remove_end_index = backup_file_count - max_keeps - 1
        backup_file_list[0..remove_end_index].each do |file|
          begin
            FileUtils.rm(file)
          rescue => e
            logger.debug "Deleting #{file} failed: #{e.message}"
          end
        end
      end
    end

    # Move back backup file from temp dir and delete tempdir etc
    def cleanup
      clear_tempdir
      @backup_file_list = nil
    end

    def tar_filename
      @tar_filename ||= -> () {
        timestamp = backup_information[:backup_created_at].strftime('%s_%Y%m%d-%H%M')
        zealot_version = backup_information[:zealot_version]
        "#{timestamp}_#{zealot_version}#{FILENAME_SUFFIX}"
      }.call
    end

    def tmpdir
      return @tmpdir if @tmpdir && Dir.exist?(@tmpdir)

      @tmpdir ||= Dir.mktmpdir(TEMPDIR_PREFIX)
    end

    def clear_tempdir
      return unless @tmpdir

      FileUtils.remove_entry(@tmpdir) if Dir.exist?(@tmpdir)
      @tmpdir = nil
    end

    private

    def tar_file
      File.join(@backup_path, tar_filename)
    end

    def backup_root_path
      @backup_root_path ||= Setting.backup[:path] || DEFAULT_BACKUP_PATH
    end

    def backup_information_file
      File.join(tmpdir, 'backup_information.yml')
    end

    #####################################################################

    # def unpack
    #   FileUtils.mkdir_p(path)

    #   Dir.chdir(path) do
    #     # check for existing backups in the backup dir
    #     if backup_file_list.empty?
    #       logger.debug "No backups found in #{path}"
    #       logger.debug "Please make sure that file name ends with #{FILENAME_SUFFIX}"
    #       exit 1
    #     elsif backup_file_list.many? && ENV["BACKUP"].nil?
    #       logger.debug 'Found more than one backup:'
    #       # print list of available backups
    #       logger.debug " " + available_timestamps.join("\n ")
    #       logger.debug 'Please specify which one you want to restore:'
    #       logger.debug 'rake zealot:backup:restore BACKUP=timestamp_of_backup'
    #       exit 1
    #     end

    #     tar_file = backup_file_list.first
    #     unless File.exist?(tar_file)
    #       logger.debug "The backup file #{tar_file} does not exist!"
    #       exit 1
    #     end

    #     logger.debug 'Unpacking backup ... ', false
    #     if system(*%W(tar -xf #{tar_file}))
    #       return true
    #     else
    #       logger.error 'Unpacking backup failed'
    #       exit 1
    #     end
    #   end
    # end

    # def verify_backup_version
    #   Dir.chdir(path) do
    #     # restoring mismatching backups can lead to unexpected problems
    #     current_version = Setting.version
    #     if settings[:zealot_version] != current_version
    #       logger.debug(<<~HEREDOC.color(:red))
    #         Zealot version mismatch:
    #           Your current Zealot version (#{current_version}) differs from the Zealot version in the backup!
    #           Please switch to the following version and try again:
    #           version: #{settings[:zealot_version]}
    #       HEREDOC
    #       logger.debug
    #       logger.debug "Hint:"
    #       logger.debug "  1. git checkout v#{settings[:zealot_version]}"
    #       logger.debug "  2. docker pull tryzealot/zealot:#{settings[:zealot_version]}"
    #       exit 1
    #     end
    #   end
    # end

    def backup_information
      @backup_information ||= {
        zealot_version: Setting.version,
        backup_created_at: Time.now,
        db_version: ActiveRecord::Migrator.current_version.to_s,
        tar_version: tar_version,
        pg_version: pg_version,
        vcs_ref: Setting.vcs_ref || false,
        docker_tag: ENV['DOCKER_TAG'] || false
      }
    end

    def backup_file_list
      @backup_file_list ||= Dir.glob(File.join(backup_path, "*#{FILENAME_SUFFIX}")).select do |file|
        FILE_REGEX.match(File.basename(file))
      end.sort_by do |file|
        FILE_REGEX.match(File.basename(file))[1]
      end
    end

    def backup_contents
      precheck_content(ARCHIVES_TO_BACKUP) + precheck_content(FOLDERS_TO_BACKUP) + ['backup_information.yml']
    end

    def precheck_content(source)
      source.each_with_object([]) do |item, obj|
        obj << item if File.exist?(File.join(tmpdir, item))
      end
    end

    def settings
      @settings ||= YAML.load_file('backup_information.yml')
    end

    def tar_version
      @tar_version ||= `#{tar} --version`.dup
        .force_encoding('locale')
        .split("\n")
        .first
        .strip
    end

    def pg_version
      @pg_version ||= `pg_dump -V`.dup
        .force_encoding('locale')
        .strip
    end
  end
end
