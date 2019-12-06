#!/bin/sh
set -eo pipefail

cd /app

mkdir -p tmp/pids tmp/cache tmp/sockets log

if [ "$1" = 'run_server' ]; then
  # Init database
  rails db:create
  rails db:migrate
  rails db:seed

  # Update cron jobs
  bundle exec whenever --update-crontab

  # Start the server
  echo "Running zealot server ..."
  bundle exec puma -C config/puma.rb
elif [ "$1" = 'run_worker' ]; then
  # Start the sidekiq
  echo "Running zealot worker ..."
  bundle exec sidekiq -C config/sidekiq.yml.erb
fi

exec "$@"