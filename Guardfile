# frozen_string_literal: true

if `uname`.match?(/Darwin/)
  ENV['TERMINAL_NOTIFIER_BIN'] ||= '/usr/local/bin/terminal-notifier'
  notification :terminal_notifier
end

ignore_rails = ENV['IGNORE_RAILS'] || 'false'

environment = ENV.fetch('RAILS_ENV', 'development')

### Guard::Sidekiq
#  available options:
#  - :verbose
#  - :queue (defaults to "default") can be an array
#  - :concurrency (defaults to 1)
#  - :timeout
#  - :environment (corresponds to RAILS_ENV for the Sidekiq worker)
guard :sidekiq, environment: environment, concurrency: 5 do
  watch(%r{^config/sidekiq.yml$})
  watch(%r{^app/jobs/(.+)\.rb$})
end

guard :webpacker do
  watch(%r{^app/javascript/(channels|javascripts|packs)/.*$})
  watch('config/webpacker.yml')
  watch(%r{^config/webpack/.*$})
end

# Guard-Rails supports a lot options with default values:
# daemon: false                        # runs the server as a daemon.
# debugger: false                      # enable ruby-debug gem.
# environment: 'development'           # changes server environment.
# force_run: false                     # kills any process that's holding the listen
#                                        port before attempting to (re)start Rails.
# pid_file: 'tmp/pids/[RAILS_ENV].pid' # specify your pid_file.
# host: 'localhost'                    # server hostname.
# port: 3000                           # server port number.
# root: '/spec/dummy'                  # Rails' root path.
# server: thin                         # webserver engine.
# start_on_start: true                 # will start the server when starting Guard.
# timeout: 30                          # waits untill restarting the Rails server, in seconds.
# zeus_plan: server                    # custom plan in zeus, only works with `zeus: true`.
# zeus: false                          # enables zeus gem.
# CLI: 'rails server'                  # customizes runner command. Omits all options except `pid_file`!
guard :rails, host: '0.0.0.0', environment: environment do
  ignore(%r{^config/(locales|webpack)/.*})
  ignore(%r{^lib/tasks/.*})

  watch('.env')
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
  watch('app/assets/config/manifest.js')
end if ignore_rails == 'false'

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

# guard :migrate do
#   watch(%r{^db/migrate/(\d+).+\.rb})
#   watch('db/seeds.rb')
# end
