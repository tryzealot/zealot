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

      if (vcs_ref = Setting.vcs_ref) && vcs_ref.present?
        release = [Setting.version, vcs_ref]
        if (docker_tag = ENV['DOCKER_TAG']) && docker_tag.present?
          release << ENV['DOCKER_TAG']
        end

        config.release = release.join('-')
      end
    end
  end
end
