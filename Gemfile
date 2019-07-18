# frozen_string_literal: true

source 'https://gems.ruby-china.com'

gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0.0.rc1'
gem 'rails-i18n', '~> 5.1'
gem 'rake', '~> 12.3.2'

# DB & Cache
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'redis-rails', '~> 5.0.1'

# API
gem 'active_model_serializers', '~> 0.10.9'
gem 'graphiql-rails' # Web IDE
gem 'graphql'
gem 'rack-cors', '~> 0.4.1'

# View
## 模板引擎
gem 'slim-rails', '~> 3.2.0'
## 表单生成
gem 'simple_form', '~> 4.1'

gem 'multi_xml'

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
gem 'devise', '~> 4.4.3'
gem 'omniauth-google-oauth2', '~> 0.7.0'
# Crontab
gem 'whenever', require: false
# # GEO 坐标计算
# gem 'haversine'

# Jenkins SDK
gem 'jenkins_api_client'
# 生成条形码/二维码
gem 'rqrcode'
# 个性化时间解析
gem 'chronic'
# 异步队列
gem 'sidekiq', '< 6'
# 支持 sidekiq 使用界面
gem 'sinatra', '~> 2.0.0', require: false
# Mobile config
gem 'settingslogic'

# Assets
gem 'coffee-rails', '~> 5.0.0'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'js-routes'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 4.0'

# JS Ace 文本编辑器
gem 'ace-rails-ap'

# 用于解析 ipa 和 apk 包
gem 'app-info', '~> 1.0.4', require: false

# 异常处理
gem 'exception_handler', '~> 0.7.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development do
  # 调试控制台
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # 断点调试器
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'guard-bundler', require: false
  gem 'guard-migrate', require: false
  gem 'guard-rails', require: false
  gem 'guard-sidekiq', require: false
  gem 'terminal-notifier', require: false
  gem 'terminal-notifier-guard', require: false

  # IDE tools(VSCode)
  # gem "ruby-debug-ide"
  # gem "debase", '~> 0.2.3.beta2' # ruby 2.5 兼容有问题暂时关闭

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'awesome_print'
  gem 'better_errors'
end

group :development, :test do
  # gem 'dotenv-rails'
  gem 'letter_opener'
  gem 'rubocop', '~> 0.45', require: false

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'graphiql-rails', group: :development