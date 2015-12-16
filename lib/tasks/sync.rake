namespace :sync do

  desc "Update chatroom id to group id"
  task :update_id => :environment do
    Message.find_in_batches do |messages|
      messages.each do |m|
        puts "[#{m.id}] update"
        group = Group.find_by(name: m.group_name, type: m.group_type)
        m.group = group
        m.save
      end
    end
  end

  desc "Sync all group(chatroom and discuss)"
  task :group => :environment do
    puts " * Fetching chatrooms"
    if Group::where(type: 'chatroom').count < Qyer::Chatroom.count
      Qyer::Chatroom.all.each_with_index do |c, i|
        puts " -> [#{c.chatroom_name}] Inserted"
        Group.find_or_create_by(
          qyer_id: c.id,
          im_id: c.im_topic_id,
          name: c.chatroom_name,
          type: 'chatroom'
        )
      end
    else
      puts " -> Not found new chatroom"
    end

    puts " * Fetching discuss"
    if Group::where(type: 'discuss').count < Qyer::Chatroom.count
      Qyer::Discuss.all.each_with_index do |d, i|
        puts " -> [#{d.group_name}] Inserted"
        Group.find_or_create_by(
          qyer_id: d.id,
          im_id: d.chatroom_id,
          name: d.group_name.gsub('discuss_', ''),
          type: 'discuss'
        )
      end
    else
      puts " -> Not found new discuss"
    end
  end


  desc "Sync Arrownock chatroom messages"
  task :messages => :environment do
    require 'rest_client'
    require 'multi_json'
    require 'awesome_print'

    url = 'http://api.im.qyer.com/v1/im/topics/history.json'
    params = {
      :key => '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
      :limit => 100,
      :b => 1
    }

    group_total = Group.count
    Group.all.each_with_index do |g, gi|
      params[:topic_id] = g.im_id
      begin
        r = RestClient.get url, {:params => params}
        data = MultiJson.load r
        puts "-> [#{gi + 1}/#{group_total}] #{g.name} - #{g.type}"
        if data['meta']['code'] == 200
          puts " * count: #{data['response']['messages'].size}"
          data['response']['messages'].each_with_index do |m, mi|
            begin
              member = Member.find_by(im_user_id: m['from'])
              group = Group.find_by(im_id: m['topic_id'])
              timestamp = Time.at(m['timestamp'] / 1000).to_datetime

              unless member
                puts " * [ERROR] not found user: #{m['from']}"
              end

              one_message = Message.find_by(im_id:m['msg_id'])
              if one_message && one_message.timestamp >= timestamp
                puts " * No new data: #{one_message.timestamp} <--> #{timestamp}"
                break
              end

              Message.find_or_create_by(im_id:m['msg_id']) do |message|
                message.im_id = m['msg_id']
                message.im_user_id = m['from']
                message.im_topic_id = m['topic_id']
                message.user_id = member.user_id
                message.user_name = member.people.username
                message.group_id = group.id
                message.group_name = group.name
                message.group_type = group.type
                message.message = m['message'] if m['content_type'] == 'text'
                message.custom_data = MultiJson.dump(m['customData'])
                message.content_type = m['content_type']
                message.file_type = (m['fileType'] || nil)
                message.file =  m['message'] if m['content_type'] != 'text'
                message.timestamp = timestamp
              end

              puts " * [#{mi + 1}] #{m['msg_id']} updated"
            rescue => e
              puts " * [EXCEPTION] #{e.message}, entry data:"
              puts m
            end
          end
        else
          puts " * [Error] API exception! entry data:"
          puts data
        end
      rescue => e
        puts " * [EXCEPTION] #{e.message}"
        next
      end
    end
  end
end