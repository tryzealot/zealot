# frozen_string_literal: true

sidekiq_config = { url: ENV['ACTIVE_JOB_URL'] || 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
  config.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
