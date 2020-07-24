# frozen_string_literal: true

# 默认开启 Sentry，如果不想使用设置 ZEALOT_SENTRY_DISABLE=1
if ENV['ZEALOT_SENTRY_DISABLE'].blank?
  Rails.configuration.to_prepare do
    Raven.configure do |config|
      config.silence_ready = true
      config.dsn = ENV['ZEALOT_SENTRY_DNS'] || 'https://133aefa9f52448a1a7900ba9d02f93e1@sentry.io/1878137'
      config.excluded_exceptions += [
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound',
        'ActiveRecord::RecordInvalid'
      ]
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
      config.sanitize_fields << 'token'

      version = Setting.version
      vcs_ref = Setting.vcs_ref
      version = "#{version}-#{vcs_ref}" if vcs_ref.present?
      config.release = version

      if vcs_ref.present?
        config.tags = {
          docker: true,
          docker_tag: ENV['DOCKER_TAG']
        }
      end
    end
  end
end
