require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'airbrussh/capistrano'

require 'capistrano/rvm'

require 'capistrano/bundler'
require 'capistrano/yarn'

require 'whenever/capistrano'

require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx

require 'capistrano/sidekiq'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
