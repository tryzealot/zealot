source 'https://gems.ruby-china.org'

gem 'puma', '~> 3.9.1'
gem 'rails', '~> 5.1.2'

# DB & Cache
gem 'mysql2', '~> 0.4.0'
gem 'redis-namespace', '~> 1.5.3'
gem 'redis-rails', '~> 5.0.1'

# APM
gem 'newrelic_rpm'

# API
gem 'active_model_serializers', '~> 0.10.5'
gem 'rack-cors', '~> 0.4.1'

# View
## 模板引擎
gem 'slim-rails', '~> 3.1.1'
## 表单生成
gem 'simple_form', '~> 3.5.0'
gem 'multi_xml'

# Model
## 生成友好 id
gem 'friendly_id'
## 数据分页
gem 'kaminari'
## 记录 Model 层记录变更
gem 'paper_trail', '~> 7.0.0' # 5.2.0'
## 文件上传
gem 'carrierwave'
gem 'mini_magick'

# Helper
# HTTP 请求
gem 'http'
# 用户认证
gem 'devise', '~> 4.3.0'
# Crontab
gem 'whenever', require: false
# # GEO 坐标计算
# gem 'haversine'

# Jenkins SDK
gem 'jenkins_api_client'
# User-Agent 封装
gem 'browser', '~> 2.3'
# 生成条形码/二维码
gem 'rqrcode'
# 个性化时间解析
gem 'chronic'
# 进程管理
gem 'foreman'
# 异步队列
gem 'sidekiq', '~> 4.2.6'
# 支持 sidekiq 使用界面
gem 'sinatra', '~> 2.0.0', require: false
# Mobile config
gem 'settingslogic'

# Assets
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'js-routes'
gem 'sass-rails'
gem 'turbolinks'
gem 'uglifier'

# JS Ace 文本编辑器
gem 'ace-rails-ap'

# 用于解析 ipa 和 apk 包
gem 'app-info', '~> 1.0.3', require: false

# 异常处理
gem 'exception_handler', '~> 0.7.0'

group :development do
  # 调试控制台
  gem 'listen', '~> 3.0.5'
  gem 'web-console'

  # 断点调试器
  gem 'byebug'
  gem 'guard-rails', require: false

  # IDE tools(VSCode)
  gem "ruby-debug-ide"
  gem "debase"

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'better_errors'
  gem 'awesome_print'

  ## cap 插件
  gem 'capistrano', '~> 3.8'
  gem 'capistrano-rails', '~> 1.2'

  gem 'capistrano-bundler'
  gem 'capistrano-yarn'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-puma'
end

group :development, :test do
  gem 'letter_opener'
  gem 'rubocop', '~> 0.45', require: false

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
end
