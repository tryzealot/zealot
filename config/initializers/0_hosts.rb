# frozen_string_literal: true

Rails.configuration.to_prepare do
  url_options = Setting.url_options

  Rails.application.configure do
    config.action_mailer.default_url_options = url_options
  end

  Rails.application.routes.default_url_options = url_options
end