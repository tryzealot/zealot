# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc "Syncing chatroom message"
task :sync_message => :environment do
  require 'rest_client'
  require 'multi_json'
  require 'awesome_print'

  url = 'http://api.im.qyer.com/v1/im/topics/history.json'
  params = {
    :key => '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
    :limit => 100,
    :b => 1
  }

  Chatroom.all.each do |c|
    params[:topic_id] = c.im_topic_id
    r = RestClient.get url, {:params => params}
    data = MultiJson.load r

    puts "-> #{c.chatroom_name}"
    if data['meta']['code'] == 200
      puts " * count: #{data['response']['messages'].size}"
      data['response']['messages'].each do |m|
        begin
          member = Member.find_by(im_user_id:m['from'])
          chatroom = Chatroom.find_by(im_topic_id:m['topic_id'])

          next unless member

          Message.find_or_create_by(im_id:m['msg_id']) do |message|
            message.im_id = m['msg_id']
            message.im_user_id = m['from']
            message.im_topic_id = m['topic_id']
            message.user_id = member.user_id
            message.user_name = member.people.username
            message.chatroom_id = chatroom.id
            message.chatroom_name = chatroom.chatroom_name
            message.message = m['message'] if m['content_type'] == 'text'
            message.custom_data = MultiJson.dump(m['customData'])
            message.content_type = m['content_type']
            message.file_type = (m['fileType'] || nil)
            message.file =  m['message'] if m['content_type'] != 'text'
            message.timestamp = Time.at(m['timestamp'] / 1000).utc
          end
        rescue Exception => e
          ap e
          ap m
        end
      end
    else
      puts "* Error: "
      ap data
    end
  end
end
