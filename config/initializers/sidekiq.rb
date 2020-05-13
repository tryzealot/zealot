# frozen_string_literal: true

def env_key_enabled?(key)
  return false unless value = ENV[key]
  return false if value.blank?
  return true if value.to_i == 1
  return true if value.downcase == 'true'

  false
end

sidekiq_config = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

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

  keep_uploads = env_key_enabled?('ZEALOT_KEEP_UPLOADS')
  cron_jobs.delete_if { |k, _| keep_uploads && k == 'clean_old_releases' }

  demo_mode = env_key_enabled?('ZEALOT_DEMO_MODE')
  cron_jobs.delete_if { |k, _| !demo_mode && k == 'reset_for_demo_mode' }

  # 从 demo mode 禁用后需要删除定时任务
  Sidekiq::Cron::Job.destroy('reset_for_demo_mode') unless demo_mode

  Sidekiq::Cron::Job.load_from_hash cron_jobs
end
