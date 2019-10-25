# frozen_string_literal: true

port     = ENV.fetch('ZEALOT_PORT') { 3000 }
host     = ENV.fetch('ZEALOT_DOMAIN') { "localhost:#{port}" }

Rails.application.configure do
  https = Rails.env.production? || ENV['ZEALOT_USE_HTTPS'] == 'true'
  url_options = { host: host, protocol: https ? 'https://' : 'http://', trailing_slash: false }

  config.x.local_domain = host
  config.x.use_https    = https
  config.x.url_options = url_options
  config.x.host = "#{url_options[:protocol]}#{url_options[:host]}"

  config.action_mailer.default_url_options = url_options
end

Rails.application.routes.default_url_options = Rails.configuration.x.url_options
