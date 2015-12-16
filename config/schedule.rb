# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# job_type :rake, "cd :path && RAILS_ENV=development bundle exec rake :task --silent :output"

every 1.day do
  rake 'sync:group', output: {
    error: 'log/cron_sync_group_error.log',
    standard: 'log/cron_sync_group.log'
  }
end

every 30.minutes do
  rake 'sync:messages', output: {
    error: 'log/cron_sync_message_error.log',
    standard: 'log/cron_sync_message.log'
  }
end

every 1.day, :at => '4:30 am' do
  rake 'apps:clean', output: {
    error: 'log/cron_apps_clean_error.log',
    standard: 'log/cron_apps_clean.log'
  }
end

# Learn more: http://github.com/javan/whenever
