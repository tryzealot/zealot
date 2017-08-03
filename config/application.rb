require_relative 'boot'

# require 'rails/all'
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QMobile
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    config.i18n.default_locale = :'zh-CN'

    # Redis for cache
    config.cache_store = :redis_store, (ENV['REDIS_URL'] || 'redis://localhost:6379/0/cache'), {
      namespace: 'qyer:mobile:web',
      expires_in: 90.minutes
    }

    # gem: exception_handler
    config.exception_handler = { dev: false }

    # Auto load path
    config.autoload_paths << Rails.root.join('app/graphql')
    config.autoload_paths << Rails.root.join('app/graphql/types')
    config.autoload_paths += Dir["#{config.root}/lib/mobile/**/*"]

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
