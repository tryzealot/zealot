# frozen_string_literal: true

# Disable error report to set ZEALOT_SENTRY_DISABLE=true, enabled by default.
if !ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_SENTRY_DISABLE'] || false)
  Rails.configuration.to_prepare do
    Sentry.init do |config|
      config.dsn = ENV['ZEALOT_SENTRY_DNS'] || 'https://133aefa9f52448a1a7900ba9d02f93e1@o333914.ingest.us.sentry.io/1878137'

      config.enable_logs = true
      config.release = Setting.version
      config.sdk_logger = Rails.logger
      config.debug = Rails.env.development?
      config.environment = Rails.env
      config.enabled_environments = %w[production development]
      config.include_local_variables = true
      config.rails.report_rescued_exceptions = true
      config.rails.structured_logging.enabled = true
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

      # Adjust the sample rates to avoid high volume of events
      config.traces_sample_rate = 0.25
      config.profiles_sample_rate = nil

      config.before_send_transaction = lambda do |event, _hint|
        # Rails.logger.debug("Sentry Transaction: #{event.transaction}")
        next nil if event.transaction =~ /HealthCheck/
        event
      end
    end

    Sentry.set_tags(
      docker_tag: ENV['DOCKER_TAG'].presence || 'development',
      vcs_ref: Setting.vcs_ref.presence,
      locale: I18n.default_locale
    )
  end
end
