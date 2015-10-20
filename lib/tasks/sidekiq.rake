namespace :sidekiq do

  desc "test"
  task :test => :environment do
    # ChatroomStatsWorker.perform_async('2015-10-01', '2015-10-08')
    ChatroomStatsJob.perform_later '2015-09-01', '2015-10-19'
  end

  task :cache => :environment do
    # Rails.cache.fetch("name") do
    #   "icyleaf"
    # end

    puts Rails.cache.read("im_chatrooms")
  end
end