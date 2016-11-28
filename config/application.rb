require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Im
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    config.i18n.default_locale = :'zh-CN'

    # Redis for cache
    config.cache_store = :redis_store, ENV['REDIS_URL'], {
      namespace: 'qyer:mobile:web',
      expires_in: 90.minutes
    }

    # Auto load path
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.assets.paths << Rails.root.join('lib', 'assets', 'javascripts')
  end
end
