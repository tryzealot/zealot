# frozen_string_literal: true

source 'https://gems.ruby-china.com'
# source 'https://rubygems.org'

ruby '>= 2.4.0', '< 2.7.0'

gem 'puma', '~> 4.3.1'
gem 'rails', '~> 6.0.1'
gem 'rails-i18n', '~> 6.0.0'
gem 'rake', '~> 13.0.1'

# DB & Cache
gem 'pg', '>= 0.18', '< 2.0'
gem 'redis', '~> 4.1.3'

# API
gem 'active_model_serializers', '~> 0.10.10'
gem 'graphql', '~> 1.9.16'
gem 'rack-cors', '~> 1.1.0'

# View
## 模板引擎
gem 'jb', '~> 0.7.0'
gem 'slim-rails', '~> 3.2.0'
## 生成 ios download plist
gem 'multi_xml'
## 表单生成
gem 'simple_form', '~> 5.0'

# Model
## 生成友好 id
gem 'friendly_id'
## 数据分页
gem 'kaminari'
## 文件上传
gem 'carrierwave'
gem 'mini_magick'

# Helper
# HTTP 请求
gem 'http'
# 用户认证
gem 'devise', '~> 4.7.1'
gem 'devise-i18n', '~> 1.8.2'
gem 'omniauth-google-oauth2', '~> 0.8.0'
gem 'pundit', '~> 2.1.0'

# Crontab
gem 'whenever', '~> 1.0.0', require: false
# 系统信息
gem 'sys-filesystem', '~> 1.3.2'
gem 'vmstat', '~> 2.3.0'

# Jenkins SDK
gem 'jenkins_api_client'
# 生成条形码/二维码
gem 'rqrcode'
# 个性化时间解析
# gem 'chronic'

# 异步队列
gem 'activejob-status'
gem 'sidekiq', '<= 7'

# Mobile config
gem 'settingslogic'

# Assets
# gem 'sass-rails', '~> 6.0'
gem 'turbolinks', '~> 5'
# gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 4.2'

# 用于解析 ipa 和 apk 包
gem 'app-info', '~> 2.1.0', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development do
  # 调试控制台
  gem 'graphiql-rails', '~> 1.7.0'
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'web-console', '>= 3.3.0'

  # 调试器
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'guard-rails'
  gem 'guard-sidekiq'
  gem 'guard-webpacker'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'

  # IDE tools(VSCode)
  # gem "ruby-debug-ide"
  # gem "debase", '~> 0.2.3.beta2' # ruby 2.5 兼容有问题暂时关闭

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'awesome_print'
  gem 'better_errors'

  # 在线查看 Action Mailer 内容
  gem 'letter_opener', '~> 1.7'
  gem 'letter_opener_web', '~> 1.3'
end

group :development, :test do
  # gem 'dotenv-rails'
  gem 'rubocop', '~> 0.77'

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
