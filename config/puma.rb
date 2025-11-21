# frozen_string_literal: true

# Bind on a specific TCP address. We won't bother using unix sockets because
# nginx will be running in a different Docker container.
bind "tcp://#{ENV.fetch('BIND_ON') { '127.0.0.1:3000' }}"

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/puma.pid' }

# Puma supports threading. Requests are served through an internal thread pool.
# Even on MRI, it is beneficial to leverage multiple threads because I/O
# operations do not lock the GIL. This typically requires more CPU resources.
#
# More threads will increase CPU load but will also increase throughput.
#
# Like anything this will heavily depend on the size of your instance and web
# application's demands. 5 is a relatively safe number, start here and increase
# it based on your app's demands.
#
# RAILS_MAX_THREADS will match the default thread size for Active Record.
max_threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `environment` that Puma will run in.
#
rails_env = ENV.fetch('RAILS_ENV') { 'development' }
environment rails_env

# Puma supports spawning multiple workers. It will fork out a process at the
# OS level to support concurrent requests. This typically requires more RAM.
#
# If you're looking to maximize performance you'll want to use as many workers
# as you can without starving your server of RAM.
#
# This value isn't really possible to auto-calculate if empty, so it defaults
# to 2 when it's not set. That is heavily leaning on the safe side.
#
# Ultimately you'll want to tweak this number for your instance size and web
# application's needs.
#
# If using threads and workers together, the concurrency of your application
# will be THREADS * WORKERS.
workers_size = ENV.fetch('WEB_CONCURRENCY') { 2 }
workers workers_size
silence_single_worker_warning if rails_env == 'development'

# An internal health check to verify that workers have checked in to the master
# process within a specific time frame. If this time is exceeded, the worker
# will automatically be rebooted. Defaults to 60s.
#
# Under most situations you will not have to tweak this value, which is why it
# is coded into the config rather than being an environment variable.
worker_timeout rails_env == 'development' ? 3600 : 30

# The path to the puma binary without any arguments.
# restart_command 'puma'

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code before
# forking the application. This takes advantage of Copy On Write process
# behavior so workers use less memory. If you use this option you need to make
# sure to reconnect any threads in the `before_worker_boot` block.
# preload_app!

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments.
# plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Start the Puma control rack application on +url+. This application can
# be communicated with to control the main server. Additionally, you can
# provide an authentication token, so all requests to the control server
# will need to include that token as a query parameter. This allows for
# simple authentication.
activate_control_app "tcp://#{ENV.fetch('PUMA_CONTROL_URL') { '127.0.0.1:9293' }}", { auth_token: ENV.fetch('PUMA_CONTROL_URL_TOKEN') { 'zealot' } }

# Handle good_job
if workers_size > 0 && defined?(GoodJob)
  before_fork do
    GoodJob.logger.info { 'Before fork process.' }
    GoodJob.shutdown
  end

  before_worker_boot do
    GoodJob.logger.info { 'Starting Puma worker process.' }
    GoodJob.restart
  end

  before_worker_shutdown do
    GoodJob.logger.info { 'Stopping Puma worker process.' }
    GoodJob.shutdown
  end

  MAIN_PID = Process.pid
  at_exit do
    GoodJob.logger.info { 'Puma shutting down.' }
    GoodJob.shutdown if Process.pid == MAIN_PID
  end
end
