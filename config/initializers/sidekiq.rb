# frozen_string_literal: true

sidekiq_config = { url: ENV['ACTIVE_JOB_URL'] || 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config

  logger_level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
  logger_level = :debug if Rails.env.development?
  config.logger.level = logger_level
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

if Sidekiq.server?
  cron_jobs = Zealot::Setting.cron_jobs

  keep_uploads = ENV['ZEALOT_KEEP_UPLOADS']
  keep_uploads = keep_uploads.present? && keep_uploads.downcase != 'false'
  cron_jobs.delete_if { |k, _| keep_uploads && k == 'clean_old_releases' }
  Sidekiq::Cron::Job.load_from_hash cron_jobs
end
