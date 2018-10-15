# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, 'mobile'
set :repo_url, 'git@git.2b6.me:icyleaf/qmobile.git'
set :branch, 'develop'
set :deploy_to, '/home/wangshen/www/mobile'
set :log_level, :debug
set :keep_releases, 3

append :linked_files, "config/database.yml"
append :linked_dirs, "log", "tmp/backups", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "public/uploads", "public/mirrors", "node_modules"

# set :default_env, {
#   'JOB_WORKER_URL' => 'redis://localhost:6379/0',
#   'REDIS_URL' => 'redis://localhost:6379/0',
# }

# rvm
set :rvm_type, :user # Defaults to: :auto
set :rvm_ruby_version, '2.4.1' # Defaults to: 'default'

# bundler
# set :bundle_flags, '--deployment --quiet -- --use-system-libraries=true'
set :bundle_env_variables, { NOKOGIRI_USE_SYSTEM_LIBRARIES: 1 }

# nginx
set :nginx_server_name, 'mobile.2b6.me'
set :nginx_sites_available_path, '/home/wangshen/nginx/sites-available'
set :nginx_sites_enabled_path, '/home/wangshen/nginx/sites-enabled'

# puma
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [1, 16]
set :puma_workers, 8
set :puma_preload_app, true

namespace :deploy do
  after :finishing, 'deploy:cleanup'
  after :finishing, 'puma:config'
  after :finishing, 'puma:nginx_config'

  after :finished, 'whenever:update_crontab'
end