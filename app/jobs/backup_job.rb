# frozen_string_literal: true

require 'fileutils'

class BackupJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :schedule

  def perform(backup_id)
    @backup = Backup.find(backup_id)
    @manager = Zealot::Backup::Manager.new(backup_path, logger)

    update_status('start',
      source: @backup.key,
      file: @manager.tar_filename,
      job_id: job_id,
      jid: provider_job_id
    )

    prepare
    dump_database
    dump_apps
    pack
    cleanup

  # rescue => e
  #   status.update(step: "throw_error")
  #   # Cause issues:
  #   # 1. write directory permissions
  #   # 2. not enough disk space
  #   # 3. missing backup cli commands (pg_dump, gzip etc)
  #   message = "Failed to create backup job, because #{e.message}"
  #   logger.error message
  #   logger.error e.backtrace.join("\n")
  ensure
    update_status('ensure')
    @manager&.cleanup
  end

  private

  def prepare
    update_status(__method__)
    @manager.precheck(false)

    # Make sure storage it by direct execute this job
    unless redis.sismember(@backup.cache_job_id_key, job_id)
      redis.sadd(@backup.cache_job_id_key, job_id)
    end
    FileUtils.mkdir_p(backup_path)
  end

  def dump_database
    update_status(__method__)
    return unless @backup.enabled_database

    @manager.dump_database
  end

  def dump_apps
    update_status(__method__)
    return if @backup.enabled_apps.empty?

    @manager.dump_uploads(app_ids: @backup.enabled_apps)
  end

  def pack
    update_status(__method__)

    @manager.write_info
    @manager.pack
  end

  def cleanup
    update_status(__method__)

    clean_redis_cache
  end

  def clean_redis_cache
    if redis.sismember(@backup.cache_job_id_key, job_id)
      redis.srem(@backup.cache_job_id_key, job_id)
    end
  end

  def backup_path
    @backup_path ||= @backup.path
  end

  def update_status(value, **params)
    status[:step] = value.to_s
    status.update(params) if params
  end

  def redis
    @redis ||= Rails.cache.redis
  end
end
