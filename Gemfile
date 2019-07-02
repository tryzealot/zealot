source 'https://gems.ruby-china.com'

gem 'puma', '~> 3.11'
gem 'rails', '~> 5.1.4'
gem 'rails-i18n', '~> 5.1.1'
gem 'rake', '~> 12.3.2'

# DB & Cache
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'redis-namespace', '~> 1.5.3'
gem 'redis-rails', '~> 5.0.1'

# API
gem 'active_model_serializers', '~> 0.10.7'
gem 'rack-cors', '~> 0.4.1'
gem 'graphql'
gem 'graphiql-rails'

# View
## 模板引擎
gem 'slim-rails', '~> 3.1.3'
## 表单生成
gem 'simple_form', '~> 3.5.0'
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
gem 'turbolinks'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'js-routes'
gem 'sass-rails'
gem 'uglifier'
gem 'font-awesome-rails'
# JS Ace 文本编辑器
gem 'ace-rails-ap'

# 用于解析 ipa 和 apk 包
gem 'app-info', '~> 1.0.4', require: false

# 异常处理
gem 'exception_handler', '~> 0.7.0'

group :development do
  # 调试控制台
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # 断点调试器
  gem 'byebug'
  gem 'guard-rails', require: false
  gem 'guard-bundler', require: false
  gem 'guard-sidekiq', require: false
  gem 'guard-migrate', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'terminal-notifier', require: false

  # IDE tools(VSCode)
  # gem "ruby-debug-ide"
  # gem "debase", '~> 0.2.3.beta2' # ruby 2.5 兼容有问题暂时关闭

  # 加速开发环境
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # rails 更友好错误输出
  gem 'better_errors'
  gem 'awesome_print'

  ## cap 插件
  gem 'capistrano', '~> 3.11.0'
  gem 'capistrano-rails', '~> 1.4.0'
  gem 'capistrano-bundler', '~> 1.3.0'
  gem 'capistrano-yarn', '~> 2.0.2'
  gem 'capistrano-rvm', '~> 0.1.2'
  gem 'capistrano-sidekiq', '~> 1.0.2'
  gem 'capistrano3-puma', '~> 3.1.1'
end

group :development, :test do
  gem 'letter_opener'
  gem 'rubocop', '~> 0.45', require: false

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]