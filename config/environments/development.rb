# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Enable verbose enqueue logging output.
  config.active_job.verbose_enqueue_logs = true

  # Highlight code that triggered redirect in logs.
  config.action_dispatch.verbose_redirect_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  config.action_cable.disable_request_forgery_protection = true

  # If using a Heroku, Vagrant or generic remote development environment,
  # use letter_opener_web, accessible at  /letter_opener.
  # Otherwise, use letter_opener, which launches a browser window to view sent mail.
  if ActiveModel::Type::Boolean.new.cast(ENV['ENABLE_DEVELOPMENT_MAILER_TEST'])
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['SMTP_ADDRESS'],
      port:                 ENV['SMTP_PORT'].to_i,
      domain:               ENV['SMTP_DOMAIN'] || ENV['ZEALOT_DOMAIN'],
      user_name:            ENV['SMTP_USERNAME'].presence,
      password:             ENV['SMTP_PASSWORD'].presence,
      authentication:       ENV['SMTP_AUTH_METHOD'] == 'none' ? nil : ENV['SMTP_AUTH_METHOD'].presence || 'plain',
      enable_starttls:      ActiveModel::Type::Boolean.new.cast(ENV['SMTP_ENABLE_STARTTLS_AUTO']) ?
                              :auto : ActiveModel::Type::Boolean.new.cast(ENV['SMTP_ENABLE_STARTTLS']),
      openssl_verify_mode:  ENV['SMTP_OPENSSL_VERIFY_MODE'],
    }
  else
    config.action_mailer.delivery_method = %w[HEROKU_APP_ID VAGRANT REMOTE_DEV].select { |k| ENV[k].present? }.empty? ? :letter_opener_web : :letter_opener
  end

  # # Use an evented file watcher to asynchronously detect changes in source code,
  # # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # # Use the lowest log level to ensure availability of diagnostic information
  # # when problems arise.
  # config.log_level = :debug

  # # Debug mode disables concatenation and preprocessing of assets.
  # # This option may cause significant delays in view rendering with a large
  # # number of complex assets.
  # config.assets.debug = true

  # # Adds additional error checking when serving assets at runtime.
  # # Checks for improperly declared sprockets dependencies.
  # # Raises helpful error messages.
  # config.assets.raise_runtime_errors = true

  # if ENV['TRUST_IP']
  #   config.web_console.permissions = ENV['TRUST_IP']

  #   if defined?(BetterErrors)
  #     require 'ipaddr'
  #     BetterErrors::Middleware.allow_ip! IPAddr.new(ENV['TRUST_IP'])
  #   end
  # end

  # config.hosts << ENV['ZEALOT_DOMAIN'] if ENV['ZEALOT_DOMAIN']
end
