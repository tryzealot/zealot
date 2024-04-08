web: bin/rails server -p $PORT -e $RAILS_ENV
worker: bin/good_job 2>&1 | tee -a /app/log/worker.log
