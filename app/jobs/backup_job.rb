# frozen_string_literal: true

require 'fileutils'

class BackupJob < ApplicationJob
  queue_as :schedule

  LOCK_FILE = '.lock'

  def perform(backup_id)
    @backup = Backup.find(backup_id)

    prepare
    dump_database
    # dump_channels
    archive
    cleanup
  rescue => e
    # Cause issues:
    # 1. write directory permissions
    # 2. not enough disk space
    # 3. missing backup cli commands (pg_dump, gzip etc)
    message = "Failed to create backup job, because #{e.message}"
    logger.error message
    logger.error e.backtrace.join("\n")
  end

  private

  def archive
    manager = Zealot::Backup::Manager.new(backup_path, logger)
    manager.write_info
    manager.pack
    manager.cleanup
  end

  def prepare
    FileUtils.mkdir_p(backup_path)
    FileUtils.touch(local_file)
  end

  def cleanup
    FileUtils.rm_f(local_file)
  end

  def dump_database
    return unless @backup.enabled_database

    Zealot::Backup::Database.dump(path: backup_path)
  end

  def dump_channels
    return if @backup.enabled_channels.empty?

    Zealot::Backup::Upload.dump(path: backup_path)
  end

  def backup_path
    @backup_path ||= -> () {
      today = Time.now.strftime('%s_%Y%m%d-%H%M')
      File.join(@backup.path, today)
    }.call
  end

  def local_file
    @local_file ||= File.join(backup_path, LOCK_FILE)
  end
end
