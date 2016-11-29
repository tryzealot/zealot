source 'https://gems.ruby-china.org'

gem 'rails', '~> 5.0.0'
gem 'puma', '~> 3.6.0'

# DB & Cache
gem 'mysql2', '~> 0.4.0'
gem 'redis-rails', '~> 5.0.1'
gem 'redis-namespace'

# API
gem 'rack-cors'
gem 'active_model_serializers'

# View
## 模板引擎
gem 'slim-rails', '~> 3.1.1'
## JSON 格式化
gem 'jbuilder', '~> 2.6.0'
## 表单生成
gem 'simple_form', '~> 3.3.1'

# Model
## 生成友好 id
gem 'friendly_id'
## 数据分页
gem 'kaminari'
## 记录 Model 层记录变更
gem 'paper_trail', '~> 4.0.0'  #5.2.0'
## 文件上传
gem 'carrierwave'
gem 'mini_magick'

# Helper
# HTTP 请求
gem 'rest-client'
# 用户认证
gem 'devise', '~> 4.2.0'
# gem 'devise-i18n'
# 权限认证
# gem 'pundit'
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
# SSH
gem 'net-ssh', '~> 3.1.1'
# 进程管理
gem 'foreman'
# 异步队列
gem 'sidekiq', '~> 4.2.6'
# 支持 sidekiq 使用界面
gem 'sinatra', '~> 2.0.0.beta2', require: false
# Mobile config
gem 'settingslogic'

# Assets
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'bower-rails', '~> 0.10.0'
gem 'js-routes'
# JS Ace 文本编辑器
gem 'ace-rails-ap'

# 用于解析 ipa 和 apk 包
gem 'qyer-mobile-app', '>= 0.8.5'

group :development do
  # 调试控制台
  gem 'web-console'
  gem 'listen', '~> 3.0.5'

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'capistrano'
  ## 改善 capistrano 输出格式化
  gem 'airbrussh', require: false

  ## cap 插件
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano3-puma'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
end

group :development, :test do
  gem 'rubocop', '~> 0.45.0', require: false
  gem 'letter_opener'

  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-rescue'
end
