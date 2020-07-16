# frozen_string_literal: true

DEFAULT_JOBS = {
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

if Sidekiq.server?
  cron_jobs = DEFAULT_JOBS

  keep_uploads = Setting.keep_uploads
  cron_jobs.delete_if { |k, _| keep_uploads && k == 'clean_old_releases' }

  demo_mode = Setting.demo_mode
  cron_jobs.delete_if { |k, _| !demo_mode && k == 'reset_for_demo_mode' }

  # 从 demo mode 禁用后需要删除定时任务
  Sidekiq::Cron::Job.destroy('reset_for_demo_mode') unless demo_mode

  Sidekiq::Cron::Job.load_from_hash cron_jobs
end