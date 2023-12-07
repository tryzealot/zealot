# frozen_string_literal: true

SIDEKIQ_URL_SETUP = lambda do
  uri = URI.parse(ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
  ssl_params = uri.scheme == 'rediss' ? { verify_mode: OpenSSL::SSL::VERIFY_NONE } : nil
  port = uri.port.nil? ? '' : ":#{uri.port}"

  {
    url: "redis://#{uri.host}#{port}#{uri.path}",
    username: uri.user,
    password: uri.password,
    ssl_params: ssl_params
  }
end

sidekiq_redis_config = SIDEKIQ_URL_SETUP.call

Sidekiq.configure_server do |config|
  logger_level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
  logger_level = ::Logger::DEBUG if Rails.env.development?
  config.logger.level = logger_level
  config.concurrency = (ENV['SIDEKIQ_CONCURRENCY'] || '5').to_i
  config.redis = sidekiq_redis_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis_config
end
