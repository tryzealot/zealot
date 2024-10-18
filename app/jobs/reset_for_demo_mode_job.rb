# frozen_string_literal: true

class ResetForDemoModeJob < ApplicationJob
  queue_as :schedule

  discard_on GoodJob::Job::ActionForStateMismatchError

  def perform
    return unless demo_mode?

    clean_app_data
    init_demo_data
    # reset_jobs

    # Clear cache
    SolidCache::Entry.clear_delete
  end

  private

  def clean_app_data
    clear_all_data
    reset_table_auto_sequences
  end

  def clear_all_data
    # Application
    Metadatum.destroy_all
    DebugFile.destroy_all
    App.destroy_all

    # Admin
    Setting.destroy_all
    AppleKey.destroy_all
    User.destroy_all
  end

  def reset_table_auto_sequences
    [
      App, Scheme, Channel, Release, Device, Metadatum, DebugFile,
      Setting, AppleKey, AppleTeam, User, WebHook, Backup
    ].each do |model|
      sequence_name = ActiveRecord::Base.connection.execute(
        "SELECT pg_get_serial_sequence('#{model.table_name}', '#{model.primary_key}')"
      ).first['pg_get_serial_sequence']

      ActiveRecord::Base.connection.execute(
        "SELECT setval('#{sequence_name}', 1, false)"
      )
    end
  end

  def reset_jobs
    GoodJob::Job.all.each do |job|
      next if job.job_class == self.class.name

      job.destroy_job
    end

    GoodJob.cleanup_preserved_jobs(older_than: 1.second)
  end

  def init_demo_data
    user = CreateAdminService.new.call
    CreateSampleAppsService.new.call(user)
  end

  def demo_mode?
    return true if Setting.demo_mode

    logger.warn("Zealot is not in demo mode, can not execute ResetForDemoModeJob.")
    false
  end
end
