# frozen_string_literal: true
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
