namespace :sidekiq do
  desc 'chatroom job'
  task chatroom: :environment do
    ChatroomStatsJob.perform_later '2015-09-01', '2015-10-19'
  end

  desc 'discuss job'
  task discuss: :environment do
    DiscussStatsJob.perform_later '2015-10-07', '2015-10-30'
  end
end
