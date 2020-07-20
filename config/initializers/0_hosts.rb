# frozen_string_literal: true

https = Setting.site_https
host = Setting.site_domain

Rails.application.configure do
  url_options = {
    host: host,
    protocol: https ? 'https://' : 'http://',
    trailing_slash: false
  }

  config.x.url_options  = url_options
  config.x.use_https    = https
  config.x.local_domain = host
  config.x.host         = "#{url_options[:protocol]}#{url_options[:host]}"

  config.action_mailer.default_url_options = url_options
end

Rails.application.routes.default_url_options = Rails.configuration.x.url_options
