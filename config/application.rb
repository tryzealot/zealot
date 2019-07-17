require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zealot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading

    # Set default timezone
    config.time_zone = ENV['TIME_ZONE'] || 'Beijing'
    config.active_record.default_timezone = :local

    # Set default locale
    locale = ENV['LOCALE'] || 'zh-CN'
    config.i18n.default_locale = locale.to_sym
    config.i18n.available_locales = [locale, :en]

    # Set up logging to be the same in all environments but control the level
    # through an environment variable.
    config.log_level = ENV['LOG_LEVEL'] || 'debug'

    # Log to STDOUT because Docker expects all processes to log here. You could
    # the framework and any gems in your application.
    # or a third party host such as Loggly, etc..
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.log_tags  = %i[subdomain uuid]
    config.logger = ActiveSupport::TaggedLogging.new(logger)

    # Action mailer settings.
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['SMTP_ADDRESS'],
      port:                 ENV['SMTP_PORT'].to_i,
      domain:               ENV['SMTP_DOMAIN'],
      user_name:            ENV['SMTP_USERNAME'],
      password:             ENV['SMTP_PASSWORD'],
      authentication:       ENV['SMTP_AUTH'],
      enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true'
    }

    config.action_mailer.default_url_options = {
      host: ENV['ACTION_MAILER_HOST']
    }
    config.action_mailer.default_options = {
      from: ENV['ACTION_MAILER_DEFAULT_FROM']
    }

    # Set Redis as the back-end for the cache.
    config.cache_store = :redis_cache_store, {
      url: (ENV['REDIS_CACHE_URL'] || 'redis://localhost:6379/0'),
      namespace: ENV['REDIS_CACHE_NAMESPACE'] || 'cache'
    }

    # Set Sidekiq as the back-end for Active Job.
    active_job_queue_prefix = ENV['ACTIVE_JOB_QUEUE_PREFIX'] || 'zealot:jobs'
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "#{active_job_queue_prefix}_#{Rails.env}"

    # Action Cable setting to de-couple it from the main Rails process.
    config.action_cable.url = ENV['ACTION_CABLE_FRONTEND_URL'] || 'ws://localhost:28080'

    # Action Cable setting to allow connections from these domains.
    if origins = ENV['ACTION_CABLE_ALLOWED_REQUEST_ORIGINS']
      origins = origins.split(',')
      origins.map! { |url| /#{url}/ }
      config.action_cable.allowed_request_origins = origins
    end

    ################################################################

    # gem: exception_handler
    config.exception_handler = { dev: false }

    # Auto load path
    config.autoload_paths << Rails.root.join('app/graphql')
    config.autoload_paths << Rails.root.join('app/graphql/types')
    config.autoload_paths += Dir["#{config.root}/lib/backup/**/*"]
    config.autoload_paths += Dir["#{config.root}/lib/mobile/**/*"]

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
