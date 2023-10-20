# frozen_string_literal: true

Rails.configuration.to_prepare do
  url_options = Setting.url_options
  Rails.application.routes.default_url_options = url_options

  # Configure ActionCable request protection
  Rails.application.configure do
    if ENV.fetch('ZEALOT_DISABLE_CABLE_REQUEST_PROTECTION') { 'false' } == 'true'
      config.action_cable.disable_request_forgery_protection = true
    else
      config.action_mailer.default_url_options = url_options

      config.action_cable.allowed_request_origins = [
        /http(s)?:\/\/#{Setting.site_domain}/
      ]
    end
  end
end
