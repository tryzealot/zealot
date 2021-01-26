# frozen_string_literal: true

SCHEDULED_JOBS = {
  clean_old_releases: {
    cron: '0 6 * * *',
    class: 'CleanOldReleasesJob',
    queue: 'schedule'
  },
  reset_for_demo_mode: {
    cron: '0 0 * * *',
    class: 'ResetForDemoModeJob',
    queue: 'schedule'
  }
}

Rails.application.reloader.to_prepare do
  if Sidekiq.server?
    cron_jobs = {}
    if Setting.keep_uploads
      Sidekiq::Cron::Job.destroy('clean_old_releases')
    else
      cron_jobs[:clean_old_releases] = SCHEDULED_JOBS[:clean_old_releases]
    end

    if Setting.demo_mode
      cron_jobs[:reset_for_demo_mode] = SCHEDULED_JOBS[:reset_for_demo_mode]
    else
      Sidekiq::Cron::Job.destroy('reset_for_demo_mode')
    end

    Sidekiq::Cron::Job.load_from_hash cron_jobs
  end
end