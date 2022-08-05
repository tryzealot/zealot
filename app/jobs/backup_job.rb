# frozen_string_literal: true

require 'fileutils'

class BackupJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :schedule

  def perform(backup_id)
    update_status("started")
    @backup = Backup.find(backup_id)
    @manager = Zealot::Backup::Manager.new(backup_path, logger)

    status.update(file: File.basename(backup_path), job_id: job_id, jid: provider_job_id)

    prepare
    dump_database
    dump_apps
    archive
    cleanup
    finish

  # rescue => e
  #   status.update(step: "throw_error")
  #   # Cause issues:
  #   # 1. write directory permissions
  #   # 2. not enough disk space
  #   # 3. missing backup cli commands (pg_dump, gzip etc)
  #   message = "Failed to create backup job, because #{e.message}"
  #   logger.error message
  #   logger.error e.backtrace.join("\n")
  end

  private

  def archive
    update_status(__method__)

    @manager.write_info
    @manager.pack
  end

  def prepare
    update_status(__method__)
    FileUtils.mkdir_p(backup_path)

    # Make sure storage it by direct execute this job
    unless redis.sismember(@backup.cache_job_id_key, job_id)
      redis.sadd(@backup.cache_job_id_key, job_id)
    end
  end

  def cleanup
    update_status(__method__)
    @manager.cleanup

    clean_redis_cache
  end

  def clean_redis_cache
    if redis.sismember(@backup.cache_job_id_key, job_id)
      redis.srem(@backup.cache_job_id_key, job_id)
    end
  end

  def dump_database
    update_status(__method__)
    return unless @backup.enabled_database

    Zealot::Backup::Database.dump(path: backup_path)
  end

  def dump_apps
    update_status(__method__)
    return if @backup.enabled_apps.empty?

    Zealot::Backup::Upload.dump(path: backup_path)
  end

  def finish
    update_status(__method__)

    FileUtils.touch(File.join(backup_path, '.complate'))
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

  def update_status(value)
    status[:step] = value.to_s
  end

  def redis
    @redis ||= Rails.cache.redis
  end
end
