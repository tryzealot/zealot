# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# job_type :rake, "cd :path && RAILS_ENV=development bundle exec rake :task --silent :output"

every 1.day, at: '4:30 am' do
  rake 'apps:remove_old', output: {
    error: 'log/cron_apps_remove_old_error.log',
    standard: 'log/cron_remove_old_clean.log'
  }
end

# Learn more: http://github.com/javan/whenever
