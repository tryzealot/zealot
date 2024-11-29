# frozen_string_literal: true

if Rails.env.production? && ENV['ZEALOT_LOG_FORMAT'] != 'rails'
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
    config.lograge.enabled = true

    config.lograge.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    config.lograge.formatter = case ENV['ZEALOT_LOG_FORMAT']
                               when 'json'
                                 Lograge::Formatters::JSON.new
                               when 'lines'
                                 Lograge::Formatters::Lines.new
                               when 'graylog2'
                                 Lograge::Formatters::Graylog2.new
                               when 'ltsv'
                                 Lograge::Formatters::LTSV.new
                               else
                                 Lograge::Formatters::KeyValue.new
                               end
    config.lograge.custom_payload do |controller|
      custom_payload(controller)
    end

    config.lograge.custom_options = lambda do |event|
      options = { time: Time.zone.now }

      if exception = event.payload[:exception]
        options[:exception] = exception[0]
        options[:exception_message] = exception[1]
      end

      if exception_object = event.payload[:exception_object]
        options[:exception_backtrace] = exception_object.backtrace
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
