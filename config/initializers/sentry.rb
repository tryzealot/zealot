# frozen_string_literal: true

# Disable error report to set ZEALOT_SENTRY_DISABLE=1, enabled by default.
if Rails.env.production? && ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_SENTRY_DISABLE'] || true)
  Rails.configuration.to_prepare do
    Sentry.init do |config|
      config.dsn = ENV['ZEALOT_SENTRY_DNS'] || 'https://133aefa9f52448a1a7900ba9d02f93e1@o333914.ingest.us.sentry.io/1878137'

      config.environment = Rails.env
      config.enabled_environments = %w[production development]
      config.include_local_variables = true
      config.rails.report_rescued_exceptions = true
      config.breadcrumbs_logger = %i[active_support_logger sentry_logger http_logger]
      config.enabled_patches << :faraday << :graphql
      config.send_default_pii = true
      config.excluded_exceptions += [
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound',
        'ActiveRecord::RecordInvalid',
        'ActiveRecord::NoDatabaseError',
        'ActiveRecord::PendingMigrationError',
        'TinyAppstoreConnect::ConnectAPIError',
        'PG::ConnectionBad',
        'AppInfo::UnkownFileTypeError',
        'Interrupt',
        'SystemExit',
        'Errno::ENOSPC',
      ]

      config.release = Setting.version
    end

    Sentry.set_tags(
      docker_tag: ENV['DOCKER_TAG'].presence || 'development',
      vcs_ref: Setting.vcs_ref.presence,
      locale: I18n.default_locale
    )
  end
end
