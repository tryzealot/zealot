set :application, 'mobile'
set :repo_url, 'git@git.2b6.me:icyleaf/qmobile.git'
set :branch, 'develop'
set :deploy_to, '/home/wangshen/www/mobile'
set :scm, :git
# set :format, :pretty
set :log_level, :debug

set :linked_files, %w(config/database.yml)
set :linked_dirs, %w(bin log tmp/backups tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads)
set :keep_releases, 10
set :default_env, {
  'JOB_WORKER_URL' => 'redis://localhost:6379/0',
  'REDIS_URL' => 'redis://localhost:6379/0',
}

# rvm
set :rvm_type, :user # Defaults to: :auto
set :rvm_ruby_version, '2.3.3' # Defaults to: 'default'
# set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

# bundler
set :bundle_env_variables, nokogiri_use_system_libraries: 1
# nginx
set :nginx_server_name, 'mobile.2b6.me'
set :nginx_sites_available_path, '/home/wangshen/nginx/sites-available'
set :nginx_sites_enabled_path, '/home/wangshen/nginx/sites-enabled'
# puma
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [1, 16]
set :puma_workers, 2
set :puma_preload_app, true

namespace :bower do
  desc 'Install bower'
  task :install do
    on roles(:app) do
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
    on roles(:app), in: :groups, limit: 3, wait: 10 do
    end
  end

  after :finishing, 'deploy:cleanup'
  # after :finishing, 'puma:stop'
  after :finishing, 'puma:config'
  after :finishing, 'puma:nginx_config'

  after :finished, 'whenever:update_crontab'
  # after :finished, 'puma:start'
end

namespace :mobile do
  namespace :backup do
    desc 'Create a backup'
    task :create do
      on roles(:app) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'mobile:backup'
          end
        end
      end
    end

    desc 'Restore from a backup'
    task :restore do
      on roles(:app) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'mobile:restore'
          end
        end
      end
    end
  end
end
