# frozen_string_literal: true

sidekiq_config = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'), network_timeout: 5 }

Sidekiq.configure_server do |config|
  config.concurrency = (ENV['SIDEKIQ_CONCURRENCY'] || '5').to_i
  config.redis = sidekiq_config
  logger_level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
  logger_level = ::Logger::DEBUG if Rails.env.development?
  config.logger.level = logger_level

  ## sidekiq-failurers
  # Max limits failures
  # FIXME: comment below because sidekiq 7.0 breaking changes https://github.com/mhfs/sidekiq-failures/issues/146
  # config.failures_max_count = 5000
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
