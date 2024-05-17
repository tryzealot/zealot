# frozen_string_literal: true

class ResetForDemoModeJob < ApplicationJob
  include DemomodeHelper

  queue_as :schedule

  def perform
    unless demo_mode?
      logger.warn("Zealot is not in demo mode, can not execute ResetForDemoModeJob.")
      return
    end

    clean_app_data
    init_demo_data
    reset_jobs
  end

  private

  def clean_app_data
    # Application
    Metadatum.destroy_all
    DebugFile.destroy_all
    App.destroy_all

    # Admin
    Setting.destroy_all
    AppleKey.destroy_all
    User.destroy_all

    # Cache in DB
    SolidCache::Entry.clear_delete
  end

  def reset_jobs
    GoodJob::Job.all.each do |job|
      next if job.job_class == self.class.name
      job.destroy_job
    end
  end

  def init_demo_data
    user = CreateAdminService.new.call
    CreateSampleAppsService.new.call(user)
  end
end
