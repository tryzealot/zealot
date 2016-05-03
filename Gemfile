source 'https://gems.ruby-china.org'

gem 'rails', '~> 4.2.4'
gem 'puma', '~> 2.14.0'

# DB & Cache
gem 'mysql2', '~> 0.4'
gem 'redis-rails', '~> 4.0.0'

# View
## 模板引擎
gem 'slim-rails'
## JSON 格式化
gem 'jbuilder', '~> 2.0'
## Emoji 支持
gem 'gemoji', '~> 2.1'
## 表单生成
gem 'simple_form', '~> 3.2.1'

# Model
## 生成友好 id
gem 'friendly_id'
## 数据分页
gem 'kaminari'
## 记录 Model 层记录变更
gem 'paper_trail', '~> 4.0.0'
## 文件上传
gem 'carrierwave'

# Helper
# HTTP 请求
gem 'rest-client'
# 用户认证
gem 'devise'
gem 'devise-i18n'
# 权限认证
gem 'pundit'
# Crontab
gem 'whenever', require: false
# GEO 坐标计算
gem 'haversine'
# JS 跨域
gem 'rack-cors', require: 'rack/cors'
# Jenkins SDK
gem 'jenkins_api_client'
# User-Agent 封装
gem 'browser', '~> 2.0.3'
# 生成条形码/二维码
gem 'rqrcode'
# 个性化时间解析
gem 'chronic'
# Zip 解压缩
gem 'rubyzip', '>= 1.0.0'
# SSH
gem 'net-ssh', '~> 3.1.1'
# 进程管理
gem 'foreman'
# 异步队列
gem 'sidekiq', '~> 3.5.1'
# 支持 sidekiq 使用界面
gem 'sinatra', require: false

# JS
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'js-routes'
# JS Ace 文本编辑器
gem 'ace-rails-ap'

## React
gem 'react-rails', '~> 1.6.2'
gem 'sprockets-coffee-react'

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  # rails 更友好错误输出
  gem 'better_errors'
  # 断点调试器
  gem 'byebug'
  # 调试控制台
  gem 'web-console'
  # 关闭静态文件日志输出
  gem 'quiet_assets'
  # 支持 Chrome rails 插件用于 debug
  gem 'meta_request'

  gem 'capistrano'
  ## 改善 capistrano 输出格式化
  gem 'airbrussh', require: false

  ## cap 插件
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm'
  gem 'capistrano3-puma'
  gem 'capistrano-nginx'
  gem 'capistrano-sidekiq'
  gem 'capistrano-foreman'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-rescue'
end
