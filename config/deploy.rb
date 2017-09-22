set :application, 'mobile'
set :repo_url, 'git@git.2b6.me:icyleaf/qmobile.git'
set :branch, 'develop'
set :deploy_to, '/home/wangshen/www/mobile'
# set :format, :pretty
set :log_level, :debug

set :linked_files, %w(config/database.yml)
set :linked_dirs, %w(log tmp/backups tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads node_modules)
set :keep_releases, 10
# set :default_env, {
#   'JOB_WORKER_URL' => 'redis://localhost:6379/0',
#   'REDIS_URL' => 'redis://localhost:6379/0',
# }

# rvm
set :rvm_type, :user # Defaults to: :auto
set :rvm_ruby_version, '2.4.1' # Defaults to: 'default'
# set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

# bundler
# set :bundle_flags, '--deployment --quiet -- --use-system-libraries=true'
set :bundle_env_variables, { NOKOGIRI_USE_SYSTEM_LIBRARIES: 1 }

# nginx
set :nginx_use_ssl, true
set :nginx_server_name, 'mobile.2b6.me'
set :nginx_sites_available_path, '/home/wangshen/nginx/sites-available'
set :nginx_sites_enabled_path, '/home/wangshen/nginx/sites-enabled'

# puma
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [1, 16]
set :puma_workers, 2
set :puma_preload_app, true

namespace :deploy do
  after :finishing, 'deploy:cleanup'
  after :finishing, 'puma:config'
  after :finishing, 'puma:nginx_config'

  after :finished, 'whenever:update_crontab'
end

# after 'puma:restart', 'puma:start'