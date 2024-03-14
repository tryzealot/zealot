# frozen_string_literal: true

if Rails.env.production?
  def fetch_ip(controller)
    controller.request.remote_ip
  rescue ActionDispatch::RemoteIp::IpSpoofAttackError
    nil
  end

  def fetch_username(controller)
    controller&.current_user&.username || 'guest'
  end

  def api_payload(controller)
    {
      ip: fetch_ip(controller),
      token: controller.request.params[:token],
      channel_key: controller.request.params[:channel_key]
    }
  end

  def page_payload(controller)
    {
      ip: fetch_ip(controller),
      username: fetch_username(controller)
    }
  end

  def custom_payload(controller)
    controller.kind_of?(ActionController::API) ? api_payload(controller) : page_payload(controller)
  rescue => e
    Rails.logger.warn("Failed to append custom payload: #{e.message}\n#{e.backtrace.join("\n")}")
    {}
  end

  Rails.application.configure do
    # Better log formatting
    config.lograge.enabled = true
    io = ENV['HEROKU_APP_ID'].present? ? 'log/zealot.log' : STDOUT
    config.lograge.logger = ActiveSupport::Logger.new(io)

    config.lograge.custom_payload do |controller|
      custom_payload(controller)
    end

    config.lograge.custom_options = lambda do |event|
      options = { time: Time.zone.now }

      if exception = event.payload[:exception]
        options[:exception] = exception
      end

      if exception_object = event.payload[:exception_object]
        options[:exception_object] = exception_object
      end

      options
    end

    config.lograge.base_controller_class = [
      'ActionController::API',
      'ActionController::Base'
    ]

    config.lograge.ignore_actions = [
      'HealthCheck::HealthCheckController#index',
      'ApplicationCable::Connection#connect',
      'ApplicationCable::Connection#disconnect',
      'Admin::LogsController#retrive',
      'NotificationChannel#subscribe',
      'NotificationChannel#unsubscribe',
    ]
  end
end
