# frozen_string_literal: true

require 'fileutils'
require_relative '../../lib/zealot/backup/manager'

class BackupJob < ApplicationJob
  retry_on StandardError, attempts: 0

  queue_as :schedule

  class Error < StandardError; end
  class MaxKeepsLimitedError < Error; end

  def perform(backup_id, user_id = nil)
    @user_id = user_id
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
    remove_old
    cleanup
    notification
  ensure
    update_status('ensure')
    @manager&.cleanup
  end

  rescue_from(BackupJob::MaxKeepsLimitedError) do
    notificate_failure(
      user_id: @user_id,
      type: 'backup',
      message: t('active_job.backup.failures.max_keeps_limited', key: @backup.key)
    )
  end

  rescue_from(Zealot::Backup::DatabaseError) do |e|
    key = e.is_a?(Zealot::Backup::DumpDatabaseError) ?
      'active_job.backup.failures.dump_command' : 'active_job.backup.failures.restore_command'

    notificate_failure(
      user_id: @user_id,
      type: 'backup',
      message: t(key, message: e.message)
    )
  end

  private

  def prepare
    update_status(__method__)
    create_redis_cache
    backup_max_keeps_check

    @manager.precheck(false)
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

  def remove_old
    @manager.remove_old(@backup.max_keeps)
  end

  def cleanup
    update_status(__method__)

    clean_redis_cache
  end

  def notification
    notificate_success(
      user_id: @user_id,
      type: 'backup',
      redirect_page: url_for(controller: 'admin/backups', action: 'show', id: @backup.id),
      message: t('active_job.backup.success', key: @backup.key)
    )
  end

  def backup_max_keeps_check
    return if @backup.max_keeps < 0
    raise MaxKeepsLimitedError, 'Max keeps is zero, can not backup' if @backup.max_keeps.zero?
  end

  def create_redis_cache
    # Make sure storage it by direct execute this job
    unless redis.sismember(@backup.cache_job_id_key, job_id)
      redis.sadd(@backup.cache_job_id_key, job_id)
    end
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
