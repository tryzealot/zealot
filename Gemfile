# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'puma', '~> 5.6.2'
gem 'rails', '~> 6.1.5'
gem 'rails-i18n', '~> 6.0.0'
gem 'rake', '~> 13.0.4'

# DB & Cache
gem 'pg', '>= 0.18', '< 2.0'
gem 'redis', '~> 4.6.0'

# Logger
gem 'lograge', '~> 0.11.2'

# API
gem 'active_model_serializers', '~> 0.10.13'
gem 'graphql', '~> 2.0.4'
gem 'rack-cors', '~> 1.1.1'
gem 'health_check', '~> 3.1.0'

# View
## 模板引擎
gem 'jb', '~> 0.8.0'
gem 'slim-rails', '~> 3.3.0'

## 表单生成
gem 'simple_form', '~> 5.1'

# Model
## 生成友好 id
gem 'friendly_id', '~> 5.4.2'
## 数据分页
gem 'kaminari'
## 文件上传
gem 'carrierwave', '~> 2.2.2'
gem 'webp-ffi', '~> 0.3.1'

# Helper
## HTTP 请求
gem 'http', '~> 5.0.4'
## 用户认证
gem 'pundit', '~> 2.2.0'
gem 'devise', '~> 4.8.1'
gem 'devise-i18n', '~> 1.10.2'

gem 'omniauth', '~> 1.9'
gem 'omniauth-google-oauth2', '~> 0.8.2'
gem 'gitlab_omniauth-ldap', '~> 2.1.1', require: 'omniauth-ldap'
gem 'omniauth-feishu', '~> 0.1.6'
gem 'omniauth-gitlab', '~> 2.0.0'

## UDID
gem 'openssl', '~> 2.2.1'
gem 'plist', '~> 3.6.0'

## 系统信息
gem 'sys-filesystem', '~> 1.4.3'
gem 'vmstat', '~> 2.3.0'
gem 'pghero'
gem 'active_analytics'

## 异常报错上报
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'

## Jenkins SDK
gem 'improved_jenkins_client', '~> 1.6.7'

## 生成条形码/二维码
gem 'rqrcode'

# 异步队列
gem 'activejob-status'
gem 'sidekiq', '~> 6.4.1'
gem 'sidekiq-scheduler', '~> 3.1.1'
gem 'sidekiq-failures', '~> 1.0.1'

# Assets
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.4'

# 用于解析 iOS, Android 和 macOS 应用
gem 'app-info', '~> 2.8.2'

# 带缓存的配置库
gem 'rails-settings-cached', '~> 2.8.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.7', require: false

group :development do
  # 调试控制台
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'web-console', '>= 3.3.0'
  gem 'graphiql-rails'

  # 调试器
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'guard', '~> 2.18.0'
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'guard-rails'
  gem 'guard-sidekiq'
  gem 'guard-webpacker'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'

  # VSCode rdbg Ruby Debugger
  gem 'debug'

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'

  # 在线查看 Action Mailer 内容
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 2.0'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rubocop', '>= 0.70', require: false
  gem 'rubocop-rails', require: false

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
end