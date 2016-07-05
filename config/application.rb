require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Im
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.default_url_option = { host: Rails.application.secrets.domain_name }

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'

    # config.exceptions_app = self.routes

    # Sidekiq for active job
    config.active_job.queue_adapter = :sidekiq

    # Redis for cache
    config.cache_store = :redis_store, {
      host: 'localhost',
      port: 6379,
      db: 0,
      namespace: 'qyer:mobile:web',
      expires_in: 90.minutes
    }

    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.assets.paths << Rails.root.join('lib', 'assets', 'javascripts')
    config.assets.paths << Emoji.images_path

    config.assets.precompile << 'emoji/**/*.png'

    # config.middleware.insert_before 0, 'Rack::Cors', debug: true, logger: (-> { Rails.logger }) do
    #   allow do
    #     origins '*'
    #     resource '*', headers: :any, methods: [:get, :post, :options], max_age: 0
    #   end
    # end
  end
end
