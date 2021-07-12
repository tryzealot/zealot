# frozen_string_literal: true

# 默认开启 Sentry，如果不想使用设置 ZEALOT_SENTRY_DISABLE=1
if ENV['ZEALOT_SENTRY_DISABLE'].blank?
  Rails.configuration.to_prepare do
    Sentry.init do |config|
      config.dsn = ENV['ZEALOT_SENTRY_DNS'] || 'https://133aefa9f52448a1a7900ba9d02f93e1@sentry.io/1878137'

      config.rails.report_rescued_exceptions = true
      config.breadcrumbs_logger = [:active_support_logger, :sentry_logger, :http_logger]

      config.send_default_pii = true
      config.environment = Rails.env
      config.enabled_environments = %w[development production]

      config.excluded_exceptions += [
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound',
        'ActiveRecord::RecordInvalid',
        'ActiveRecord::NoDatabaseError',
        'PG::ConnectionBad',
      ]

      vcs_ref = Setting.vcs_ref
      if vcs_ref.present?
        version = Setting.version
        config.release = "#{version}-#{vcs_ref}"
        config.tags = {
          docker: ENV['DOCKER_TAG'].present?,
          docker_tag: ENV['DOCKER_TAG']
        }
      end
    end
  end
end
