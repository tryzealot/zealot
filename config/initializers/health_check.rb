# frozen_string_literal: true

require_relative '../../lib/zealot/goodjob_health_check'

Rails.configuration.to_prepare do
  HealthCheck.setup do |config|
    config.uri = '/api/health'

    config.include_error_in_response_body = true if Rails.env.development?

    config.standard_checks = %w[database cache]
    config.full_checks = %w[database migrations cache goodjob]

    config.add_custom_check('goodjob') do
      Zealot::GoodjobHealthCheck.check
    end

    ip_whitelist = ENV['ZEALOT_HEALTH_CHECK_IP_WHITELIST']
    ip_whitelist = ip_whitelist.split(',').select(&:present?).map(&:strip) if ip_whitelist.present?
    config.origin_ip_whitelist = ip_whitelist if ip_whitelist.present?

    # Text output upon success
    config.success = 'healthy'

    # Text output upon failure
    config.failure = 'unhealthy'

    # text and object(json/xml) failure codes are set separately
    config.http_status_for_error_text = 500
    config.http_status_for_error_object = 500
  end
end
