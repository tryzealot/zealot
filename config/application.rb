# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zealot
  class Application < Rails::Application
    VERSION = '6.0.0'

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Set default timezone
    config.time_zone = ENV['TIME_ZONE'] || 'Asia/Shanghai'
    config.active_record.default_timezone = :local

    # Set default locale
    locale = ENV['DEFAULT_LOCALE']&.to_sym
    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = %i[zh-CN en]
    config.i18n.default_locale = config.i18n.available_locales.include?(locale) ? locale : :'zh-CN'

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = [I18n.default_locale]

    # Action mailer settings.
    config.action_mailer.default_options = {
      from: ENV['ACTION_MAILER_DEFAULT_FROM'] || 'Zealot'
    }

    # Set the back-end for the cache.
    config.cache_store = :solid_cache_store

    # Set the back-end for Active Job.
    config.active_job.queue_adapter = :good_job

    # Action Cable setting to de-couple it from the main Rails process.
    # config.action_cable.url = ENV['ACTION_CABLE_FRONTEND_URL'] || 'ws://localhost:28080'
    config.action_cable.mount_path = '/cable'

    # Action Cable setting to allow connections from these domains.
    # if origins = ENV['ACTION_CABLE_ALLOWED_REQUEST_ORIGINS']
    #   origins = origins.split(',')
    #   origins.map! { |url| /#{url}/ }
    #   config.action_cable.allowed_request_origins = origins
    # end

    # Auto load path
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.eager_load_paths += Dir["#{config.root}/lib"]

    ################################################################
    # Don't generate those files.
    config.generators.javascripts = false
    config.generators.stylesheets = false
    config.generators.system_tests = false
  end
end
