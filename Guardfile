# frozen_string_literal: true

if `uname`.match?(/Darwin/)
  notification :terminal_notifier
elsif ENV['TERM'] == 'screen' && !ENV['TMUX'].empty?
  notification :tmux,
    display_message: true,
    timeout: 5, # in seconds
    default_message_format: '%s >> %s',
    line_separator: ' > ', # since we are single line we need a separator
    color_location: 'status-right-bg', # to customize which tmux element will change color

    # Other options:
    default_message_color: 'black',
    success: 'colour150',
    failed: 'colour174',
    pending: 'colour179',

    # Notify on all tmux clients
    display_on_all_clients: false
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

guard :migrate do
  watch(%r{^db/migrate/(\d+).+\.rb})
end
