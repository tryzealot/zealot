# frozen_string_literal: true

SCHEDULED_JOBS = {
  sync_apple_devices: {
    cron: '0 0 * * *',
    class: 'SyncAppleDevicesJob',

    description: 'Syncing devices for all Apple Developers on each 0AM',
  },
  clean_old_releases: {
    cron: '0 6 * * *',
    class: 'CleanOldReleasesJob',
    description: 'Clean old versions on each 6AM',
  },
  reset_for_demo_mode: {
    cron: '0 0 * * *',
    class: 'ResetForDemoModeJob',
    description: 'Reset demo data everyday'
  }
}

Rails.application.reloader.to_prepare do
  Rails.application.configure do
    config.good_job.dashboard_default_locale = :en
    config.good_job.preserve_job_records = true
    config.good_job.retry_on_unhandled_error = false
    config.good_job.on_thread_error = -> (exception) { Rails.error.report(exception) }
    config.good_job.execution_mode = :async
    config.good_job.queues = '*'
    config.good_job.max_threads = (ENV['ZEALOT_WORKER_CONCURRENCY'] || '5').to_i
    config.good_job.poll_interval = (ENV['ZEALOT_WORKER_POLL_INTERVAL'] || '30').to_i
    config.good_job.shutdown_timeout = (ENV['ZEALOT_WORKER_SHUTDOWN_TIMEOUT'] || '30').to_i

    cron_jobs = {
      sync_apple_devices: SCHEDULED_JOBS[:sync_apple_devices]
    }
    cron_jobs[:clean_old_releases] = SCHEDULED_JOBS[:clean_old_releases] unless Setting.keep_uploads
    cron_jobs[:reset_for_demo_mode] = SCHEDULED_JOBS[:reset_for_demo_mode] if Setting.demo_mode

    Backup.enabled_jobs.each do |backup|
      cron_jobs[backup.schedule_key] = backup.schedule_job
    end

    config.good_job.enable_cron = true
    config.good_job.cron = cron_jobs

    # logger_level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
    # logger_level = ::Logger::DEBUG if Rails.env.development?
    # logger = Rails.logger
    # logger.level = logger_level
    # config.good_job.logger = logger
  end
end

ActiveSupport.on_load(:good_job_application_controller) do
  content_security_policy do |policy|
    policy.frame_ancestors(:self)
  end
end
