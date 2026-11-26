# frozen_string_literal: true

Rails.application.configure do
  config.good_job.dashboard_default_locale = I18n.default_locale
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Rails.error.report(exception) }
  config.good_job.execution_mode = ENV.fetch('GOOD_JOB_EXECUTION_MODE', 'async').to_sym
  config.good_job.queues = '+webhook,default,app_parse,schedule'
  config.good_job.threads = (ENV['ZEALOT_WORKER_CONCURRENCY'] || '5').to_i
  config.good_job.poll_interval = (ENV['ZEALOT_WORKER_POLL_INTERVAL'] || '30').to_i
  config.good_job.shutdown_timeout = (ENV['ZEALOT_WORKER_SHUTDOWN_TIMEOUT'] || '30').to_i

  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 14.days
  config.good_job.cleanup_interval_jobs = 1_000
  config.good_job.cleanup_interval_seconds = 10.minutes

  config.good_job.enable_cron = ENV.fetch('GOOD_JOB_ENABLE_CRON', 'true').casecmp('true').zero?

  config.good_job.cron = {
    sync_apple_devices: {
      cron: '0 0 * * *',
      class: 'SyncAppleDevicesJob',
      description: 'Syncing devices for all Apple Developers on each 0AM'
    },
    clean_old_releases: {
      cron: '0 6 * * *',
      class: 'CleanOldReleasesJob',
      description: 'Clean old versions on each 6AM'
    },
    cleanup_preserved_jobs: {
      cron: '0 3 * * *',
      class: 'CleanupPreservedJobsJob',
      description: 'Clean up preserved good_job execution records older than 14 days'
    },
    reset_for_demo_mode: {
      cron: '0 0 * * *',
      class: 'ResetForDemoModeJob',
      description: 'Reset demo data everyday'
    }
  }

  # Zealot Pro keeps the license lease fresh. Without this the client would
  # downgrade to the community edition when the short lease expires, even if
  # the subscription is still active.
  #
  # Local development tokens are often signed for a different environment and
  # the default gateway is production; syncing there would mark the license
  # revoked. Disable the cron in development/test unless explicitly enabled.
  pro_refresh_default = Rails.env.development? || Rails.env.test? ? '0' : '1'
  pro_refresh_enabled = ENV.fetch('ZEALOT_PRO_REFRESH_ENABLED', pro_refresh_default) == '1'

  if defined?(Zealot::Pro) && pro_refresh_enabled
    config.good_job.cron[:zealot_pro_refresh] = {
      cron: ENV.fetch('ZEALOT_PRO_REFRESH_CRON', '0 3 * * *'),
      class: 'Zealot::Pro::RefreshJob',
      description: 'Refresh Zealot Pro license lease daily'
    }
  end

  config.after_initialize do
    cron_jobs = config.good_job.cron
    begin
      cron_jobs.delete(:clean_old_releases) if Setting.keep_uploads
      cron_jobs.delete(:reset_for_demo_mode) unless Setting.demo_mode

      Backup.enabled_jobs.each do |backup|
        cron_jobs[backup.schedule_key] = backup.schedule_job
      end
    rescue ActiveRecord::ActiveRecordError
    end
  end
end

ActiveSupport.on_load(:good_job_application_controller) do
  content_security_policy do |policy|
    policy.frame_ancestors(:self)
  end
end
