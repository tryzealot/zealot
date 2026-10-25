# frozen_string_literal: true

# Disable error report to set ZEALOT_SENTRY_DISABLE=true, enabled by default.
if !ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_SENTRY_DISABLE'] || false)
  Rails.configuration.to_prepare do
    Sentry.init do |config|
      config.dsn = ENV['ZEALOT_SENTRY_DNS'] || 'https://133aefa9f52448a1a7900ba9d02f93e1@o333914.ingest.us.sentry.io/1878137'

      config.release = Setting.version
      config.sdk_logger = Rails.logger
      config.debug = Rails.env.development?
      config.environment = Rails.env
      config.enabled_environments = %w[production development]

      config.rails.report_rescued_exceptions = false
      config.rails.structured_logging.enabled = true
      config.breadcrumbs_logger = %i[active_support_logger sentry_logger http_logger]
      config.enabled_patches << :faraday << :graphql

      config.data_collection.stack_frame_variables = true
      config.data_collection.user_info = true
      config.data_collection.cookies = true
      config.data_collection.http_headers.request = true

      config.excluded_exceptions += [
        'ActionController::RoutingError',
        'ActionController::MissingFile',
        'ActiveRecord::RecordNotFound',
        'ActiveRecord::RecordInvalid',
        'ActiveRecord::NoDatabaseError',
        'ActiveRecord::PendingMigrationError',
        'TinyAppstoreConnect::ConnectAPIError',
        'PG::ConnectionBad',
        'AppInfo::Error',
        'AppInfo::UnknownFormatError',
        'AppInfo::NotFoundError',
        'AppInfo::ParseError',
        'Pundit::NotAuthorizedError',
        'CarrierWave::InvalidParameter',
        'Zealot::Error::RecordNotFound',
        'Zealot::Error::AppArchivedDeny',
        'Interrupt',
        'SystemExit',
        'Errno::ENOSPC',
      ]

      default_trace_rate = ENV.fetch('ZEALOT_SENTRY_TRACES_SAMPLE_RATE', '0.02').to_f
      config.traces_sampler = lambda do |sampling_context|
        transaction_context = sampling_context[:transaction_context]
        name = transaction_context[:name] || ''

        return 0.0 if name.match?(/HealthCheck|up|health|ping/i)

        default_trace_rate
      end
      config.profiles_sample_rate = nil

      config.before_send = lambda do |event, _hint|
        headers = event.request&.headers || {}
        user_agent = headers['User-Agent'] || headers['HTTP_USER_AGENT'] || ''
        return nil if user_agent.match?(/bot|spider|crawl|scanner/i)

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
