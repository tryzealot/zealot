set :application, 'mobile'
set :repo_url, 'git@git.2b6.me:icyleaf/mobile.git'
set :branch, 'develop'
set :deploy_to, '/home/wangshen/www/mobile'
set :scm, :git
# set :format, :pretty
set :log_level, :debug

set :linked_files, %w(config/database.yml)
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/files public/gitstats)
set :keep_releases, 10
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# rvm
set :rvm_type, :user # Defaults to: :auto
set :rvm_ruby_version, '2.2.2' # Defaults to: 'default'
# set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

# bundler
set :bundle_env_variables, 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1
# nginx
set :nginx_server_name, 'mobile.2b6.me mobile.dev'
set :nginx_sites_available_path, '/home/wangshen/nginx/sites-available'
set :nginx_sites_enabled_path, '/home/wangshen/nginx/sites-enabled'
# puma
set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock" # accept array for multi-bind
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma.error.log"
set :puma_error_log, "#{shared_path}/log/puma.access.log"
set :puma_role, :web
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [1, 16]
set :puma_workers, 2
set :puma_worker_timeout, nil
set :puma_init_active_record, false
set :puma_preload_app, true
set :puma_prune_bundler, false

namespace :bower do
  desc 'Install bower'
  task :install do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'bower:install CI=true'
        end
      end
    end
  end
end
before 'deploy:compile_assets', 'bower:install'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'puma:stop'
  after :finishing, 'puma:config'
  after :finishing, 'puma:nginx_config'

  after :finished, 'whenever:update_crontab'
  after :finished, 'puma:start'
end
