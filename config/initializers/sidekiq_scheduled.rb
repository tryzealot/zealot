# frozen_string_literal: true

private def add_or_delete_schedule(remove, cron_jobs, key)
  if remove
    Sidekiq.remove_schedule(key.to_s)
  else
    cron_jobs[key] = SCHEDULED_JOBS[key]
  end
end

SCHEDULED_JOBS = {
  clean_old_releases: {
    cron: '0 6 * * *',
    class: 'CleanOldReleasesJob',
    queue: 'schedule',
    description: 'Clean old versions on each 6 AM',
  },
  reset_for_demo_mode: {
    cron: '0 0 * * *',
    class: 'ResetForDemoModeJob',
    queue: 'schedule',
    description: 'Reset demo data everyday'
  }
}

Rails.application.reloader.to_prepare do
  if Sidekiq.server?
    cron_jobs = {}
    add_or_delete_schedule(Setting.keep_uploads, cron_jobs, :clean_old_releases)
    add_or_delete_schedule(!Setting.demo_mode, cron_jobs, :reset_for_demo_mode)

    Sidekiq.schedule = cron_jobs
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end