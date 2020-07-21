# frozen_string_literal: true

HealthCheck.setup do |config|
  config.uri = 'health'

  config.standard_checks = %w[database migrations cache redis]
  config.full_checks = %w[database migrations cache redis sidekiq-redis]

  ip_whitelist = ENV.fetch('ZEALOT_HEALTH_CHECK_IP_WHITELIST') { '127.0.0.1' }
  ip_whitelist = ip_whitelist.split(',').map(&:strip)

  config.origin_ip_whitelist = ip_whitelist
end
