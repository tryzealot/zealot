#!/bin/sh
set -eo pipefail

cd /app

# 清除可能异常退出但没有请 pid 的问题
rm -f tmp/pids/.pid

mkdir -p tmp/pids tmp/cache tmp/uploads tmp/sockets log

if [ "$1" = 'run_server' ]; then
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