# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'puma', '~> 6.4.2'
gem 'rails', '~> 7.1.3'
gem 'rails-i18n', '~> 7.0.5'
gem 'rack-cors', '~> 2.0.2'
gem 'rack', '~> 3.0.11'

# DB & Cache
gem 'pg', '>= 0.18', '< 2.0'
gem "solid_cache", "~> 0.7.0"

# Logger
gem 'lograge', '~> 0.14.0'

# API
gem 'active_model_serializers', '~> 0.10.14'
gem 'graphql', '~> 2.3.13'
gem 'health_check', '~> 3.1.0'
gem 'tiny_appstore_connect', '~> 0.1.12'

# View
gem 'jb', '~> 0.8.2'
gem 'slim-rails', '~> 3.6.3'
gem 'kramdown', '~> 2.4'
gem 'simple_form', '~> 5.3'
gem 'rswag-api', '~> 2.13.0'
gem 'rswag-ui', '~> 2.13.0'

# Model
gem 'friendly_id', '~> 5.5.1'
gem 'kaminari', '~> 1.2.2'
gem 'carrierwave', '~> 3.0.7'
gem 'webp-ffi', '~> 0.4.0'

# Helper
gem 'rake', '~> 13.0.4'
gem 'rails-settings-cached', '~> 2.9.4'
gem 'app-info', '~> 3.1.4'
gem 'faraday', '~> 2.10.1'
gem 'rqrcode'

## Auth
gem 'pundit', '~> 2.3.2'
gem 'devise', '~> 4.9.4'
gem 'devise-i18n', '~> 1.12.1'

gem 'omniauth', '~> 2.1.2'
gem 'omniauth-rails_csrf_protection', '~> 1.0.2'
gem 'omniauth-google-oauth2', '~> 1.0.1'
gem 'omniauth-gitlab', '~> 3.0.0'
gem 'omniauth-feishu', '~> 0.1.8'
gem 'gitlab_omniauth-ldap', '~> 2.2.0', require: 'omniauth-ldap'
gem 'omniauth_openid_connect', '0.8.0'

## UDID
gem 'openssl', '~> 3.2.0'
gem 'plist', '~> 3.7.1'

## OS
gem 'sys-filesystem', '~> 1.5.0'
gem 'vmstat', '~> 2.3.0'
gem 'pghero', '~> 3.6.0'

## Exception handler
gem 'sentry-ruby', '~> 5.18.0'
gem 'sentry-rails', '~> 5.18.2'

# Background job
gem 'good_job', '~> 4.1.0'
gem 'activejob-status', '~> 1.0.2'

# Assets
## Use jsbundling-rails, cssbundling-rails to run rake tasks, core is build/build:css in package.json
gem 'propshaft', '0.9.0'
gem 'jsbundling-rails', '~> 1.3'
gem 'cssbundling-rails', '~> 1.4'
## Javascript
gem 'stimulus-rails', '~> 1.3.3'
gem 'turbo-rails', '~> 2.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.7', require: false

group :development do
  gem 'listen', '>= 3.0.5', '< 3.10'
  gem 'web-console', '>= 3.3.0'
  gem 'graphiql-rails'

  ## VSCode debug: https://marketplace.visualstudio.com/items?itemName=KoichiSasada.vscode-rdbg
  gem 'debug', '~> 1.9.2'

  # better rails
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'

  # helpers
  gem 'letter_opener', '~> 1.10'
  gem 'letter_opener_web', '~> 3.0'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rubocop', '>= 0.70', require: false
  gem 'rubocop-rails', require: false

  gem 'pry-rails'
  gem 'pry-rescue'

  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rswag-specs'
end
