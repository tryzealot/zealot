# frozen_string_literal: true

https = Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?
port = ENV.fetch('ZEALOT_PORT') { 3000 }
host = ENV.fetch('ZEALOT_DOMAIN') { https ? 'localhost' : "localhost:#{port}" }

Rails.application.configure do
  url_options = { host: host, protocol: https ? 'https://' : 'http://', trailing_slash: false }

  config.x.url_options  = url_options
  config.x.use_https    = https
  config.x.local_domain = host
  config.x.host         = "#{url_options[:protocol]}#{url_options[:host]}"

  config.action_mailer.default_url_options = url_options
end

Rails.application.routes.default_url_options = Rails.configuration.x.url_options
