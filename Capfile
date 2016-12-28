require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails/tree/master/assets
#   https://github.com/capistrano/rails/tree/master/migrations
#
require 'airbrussh/capistrano'
require 'capistrano/rvm'
# require 'capistrano/rbenv'

require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'whenever/capistrano'
require 'capistrano/puma'
# require 'capistrano/puma/workers' #if you want to control the workers (in cluster mode)
# require 'capistrano/puma/jungle'  #if you need the jungle tasks
# require 'capistrano/puma/monit'   #if you need the monit tasks
require 'capistrano/puma/nginx' # if you want to upload a nginx site template
require 'capistrano/sidekiq'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
