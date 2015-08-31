# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
load 'tasks/emoji.rake'

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

  chatroom_total = Chatroom.count
  Chatroom.where.not(id:143).find_all.each_with_index do |c, ci|
    params[:topic_id] = c.im_topic_id
    r = RestClient.get url, {:params => params}
    data = MultiJson.load r

    puts "-> [#{ci + 1}/#{chatroom_total}]#{c.chatroom_name}"
    if data['meta']['code'] == 200
      puts " * count: #{data['response']['messages'].size}"
      data['response']['messages'].each_with_index do |m, mi|
        begin
          member = Member.find_by(im_user_id:m['from'])
          chatroom = Chatroom.find_by(im_topic_id:m['topic_id'])
          timestamp = Time.at(m['timestamp'] / 1000).to_datetime

          unless member
            puts " * [ERROR] not found user: #{m['from']}"
          end

          one_message = Message.find_by(im_id:m['msg_id'])
          if one_message && one_message.timestamp >= timestamp
            puts " * no news: #{one_message.timestamp} <--> #{timestamp}"
            break
          end

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
            message.timestamp = timestamp
          end


          puts " * [#{mi + 1}] #{m['msg_id']} updated"
        rescue Exception => e
          puts " * [EXCEPTION] #{e.message}, entry data:"
          puts m
        end
      end
    else
      puts " * [Error] API exception! entry data:"
      puts data
    end
  end
end

desc "发分享"
task :send_poi do
  url = 'http://api.im.qyer.com/v1/im/notice.json'
  custom_data = {
    tipText: "有时间来我们这里转转！",
    content: "欢迎来坐坐！",
    action: "share",
    fromUserName: "特卖专员",
    attribute4: 0,
    attribute5: 0,
    title: "穷游清迈Q-Home",
    wid: "279953",
    type: 9,
    fromUserAvatar: "http://static.qyer.com/data/avatar/001/07/13/21_avatar_big.jpg?v=1411745284",
    photo: "http://pic.qyer.com/album/user/1284/52/QEtdRh8FZEA/index/w800"
  }

  params = {
    key: '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
    from: 'AIMBFBGWKNHZ5YE0EBQIM3D',
    topic: '547eb6811444529ad8000091',
    notice: 'SHARE_TO_CHATROOM',
    # msg_id: SecureRandom.hex(10),
    custom_data: MultiJson.dump(custom_data)
  }

  ap params

  r = RestClient.post url, params
  ap MultiJson.load r
end