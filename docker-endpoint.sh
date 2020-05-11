#!/bin/sh
set -eo pipefail

cd /app

# Clear pid if unexpected exception exit
rm -f tmp/pids/.pid

mkdir -p tmp/pids tmp/cache tmp/uploads tmp/sockets log

if [ "$1" = 'run_server' ]; then
  if [ -d "new_public" ]; then
    echo "Zealot updating public ..."
    for x in public/*; do
      if [ -z `echo $x | grep uploads` ]; then
        rm -rf $x
      fi
    done

    for x in new_public/*; do
      if [ -z `echo $x | grep uploads` ]; then
        mv $x public
      fi
    done

    rm -rf new_public
  fi

  # Start the server
  echo "Zealot server is ready to run ..."
  bundle exec puma -C config/puma.rb
elif [ "$1" = 'run_worker' ]; then
  # Start the sidekiq
  echo "Zealot worker is wait the comming job ..."
  bundle exec sidekiq -C config/sidekiq.yml
elif [ "$1" = 'run_upgrade' ]; then
  ./bin/rails zealot:upgrade
  exit 0
fi

exec "$@"