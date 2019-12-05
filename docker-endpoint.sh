#!/bin/sh
set -eo pipefail

if [ "$1" = 'run_server' ]; then
  # Init database
  bundle exec rails db:create
  bundle exec rails db:migrate
  bundle exec rails db:seed

  # Clean up
  rm -rf public/assets
  rm -rf public/packs

  # Compile the assets
  bundle exec rails assets:precompile
  bundle exec rails webpacker:compile

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