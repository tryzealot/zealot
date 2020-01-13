#!/bin/sh
set -eo pipefail

cd /app

mkdir -p tmp/pids tmp/cache tmp/uploads tmp/sockets log

ZEALOT_READY_FILE=/app/zealot.ready

# Prepare works
if [ ! -f "$ZEALOT_READY_FILE" ]; then
  echo "Waiting zealot to be ready please ... tea time"
  # Init database
  bin/rails db:create
  bin/rails db:migrate
  bin/rails db:seed

  # Update cron jobs
  bundle exec whenever --update-crontab

  echo "$ZEALOT_VERSION" > $ZEALOT_READY_FILE
  echo $(date) >> $ZEALOT_READY_FILE
fi

if [ "$1" = 'run_server' ]; then
  # Start the server
  echo "Zealot server is ready to run ..."
  bundle exec puma -C config/puma.rb
elif [ "$1" = 'run_worker' ]; then
  # Start the sidekiq
  echo "Zealot worker is wait the comming job ..."
  bundle exec sidekiq -C config/sidekiq.yml.erb
fi

exec "$@"