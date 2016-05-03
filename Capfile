# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

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
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'whenever/capistrano'
require 'capistrano/puma'
# require 'capistrano/puma/workers' #if you want to control the workers (in cluster mode)
# require 'capistrano/puma/jungle'  #if you need the jungle tasks
# require 'capistrano/puma/monit'   #if you need the monit tasks
require 'capistrano/puma/nginx' # if you want to upload a nginx site template
# require 'capistrano/git-submodule-strategy'
require 'capistrano/sidekiq'
# require 'capistrano/foreman'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
