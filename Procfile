web: bin/rails server -p $PORT -e $RAILS_ENV 2>&1 | tee -a log/zealot.log
worker: bin/good_job 2>&1 | tee -a log/worker.log
