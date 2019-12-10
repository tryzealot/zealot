#!/bin/sh
set -eo pipefail

cd /app

mkdir -p tmp/pids tmp/cache tmp/sockets log

if [ "$1" = 'run_server' ]; then
  echo "Waiting zealot to be ready please ... tea time"
  # Init database
  rails db:create
  rails db:migrate
  rails db:seed

  # Update cron jobs
  bundle exec whenever --update-crontab

  # Start the server
  echo "Zealot server is ready to run ..."
  bundle exec puma -C config/puma.rb
elif [ "$1" = 'run_worker' ]; then
  # Start the sidekiq
  echo "Zealot worker is wait the comming job ..."
  bundle exec sidekiq -C config/sidekiq.yml.erb
fi

exec "$@"