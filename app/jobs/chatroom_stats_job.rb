class ChatroomStatsJob < ActiveJob::Base
  queue_as :default

  CITY_CHATROOMS_KEY = 'im_chatrooms'.freeze
  JK_KEY = '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx'.freeze

  IM_SERVER = '23.91.98.3'.freeze
  IM_USER = 'root'.freeze
  IM_PWD = 'im.server!QAZ@WSX'.freeze
  IM_PORT = 2233.freeze

  def perform(start_date, end_date)
    chatroom_total_stats = []
    @chatrooms = city_chatrooms!
    @start_date = Chronic.parse((start_date || 'yesterday') + ' 0:00')
    @end_date = Chronic.parse((end_date || 'today') + ' 23:59')
    @total_days = end_date.to_datetime.mjd - start_date.to_datetime.mjd

    puts "#{@start_date} - #{@end_date}"

    ###################################
    puts " * Connecting im server..."
    ###################################
    chatroom_ids = @chatrooms.keys

    Net::SSH.start(IM_SERVER, IM_USER, password: IM_PWD, port: IM_PORT) do |ssh|
      current_date = @start_date.to_date
      until @end_date.to_date < current_date
        start_timestamp = current_date.to_time.to_i * 1000

        puts " -> #{current_date}"
        puts "    Fetching chatroom messages total: [#{start_timestamp.to_s}]"

        message_count_key = "chatroom_message_count_#{start_timestamp.to_s}"
        date_messages = Rails.cache.fetch(message_count_key) do
          MultiJson.load(ssh.exec!([
            "/opt/arrownock/db-scripts/get_chat_room_message_count.sh",
            JK_KEY,
            start_timestamp.to_s,
          ].join(" ")))
        end

        date_messages.each do |topic_id, item|
          # 艾普罗菲尔，穷游办公室跳过
          next if ["53ba02e7144452cd76000004", "547eb6811444529ad8000091"].include?topic_id
          # 不是城市聊天室的跳过
          next unless chatroom_ids.include?topic_id

          @chatrooms[topic_id][:messages].append({
            date: current_date.strftime("%Y%m%d"),
            messages: {
              topic: item["topic"].to_i,
              notice: item["notice"].to_i,
              total: item["topic"].to_i + item["topic"].to_i,
            },
          })
        end

        puts "    Fetching chatroom register total"
        register_count_key = "chatroom_register_count_#{start_timestamp.to_s}"
        date_registers = Rails.cache.fetch(register_count_key) do
          MultiJson.load(ssh.exec!([
            "/opt/arrownock/db-scripts/get_chat_room_new_uesr_count.sh",
            JK_KEY,
            start_timestamp.to_s,
          ].join(" ")))
        end

        date_registers.each do |topic_id, item|
          # 艾普罗菲尔，穷游办公室
          next if ["53ba02e7144452cd76000004", "547eb6811444529ad8000091"].include?topic_id
          @chatrooms[topic_id][:registers].append({
            date: current_date.strftime("%Y%m%d"),
            total: item,
          })
        end

        current_date += 1

      end #/until
    end #/Net::SSH


    ###################################
    puts " * Getting hottest chatrooms"
    ###################################
    members = []
    chatrooms_max_members = chatroom_max_members(@chatrooms.length)
    if chatrooms_max_members.is_a?Hash
      if chatrooms_max_members['meta']['code'] == 200
        chatrooms_max_members['response']['topics'].each do |item|
          members.append({
            chatroom: item["name"],
            members: item["parties_count"]
          })
        end
      else
        puts " -> Error: #{chatrooms_max_members.to_s}"
      end
    else
      puts " -> Error: #{chatrooms_max_members}"
    end

    puts " * Fetching each chatroom messages"
    @chatrooms.each do |topic_id, chatroom|
      message_total = 0
      chatroom[:messages].each do |item|
        message_total += item[:messages][:total]
      end

      registers_total = 0
      chatroom[:registers].each do |item|
        registers_total += item[:total]
      end

      members_total = 0
      members.each do |item|
        if item[:chatroom] == chatroom[:name]
          members_total = item[:members]
          break
        end
      end

      chatroom_total_stats.append({
        chatroom: chatroom[:name],
        members: members_total,
        messages: message_total,
        average_message: (message_total / @total_days.to_f).round(2),
        registers: registers_total,
        average_register: (registers_total / @total_days.to_f).round(2),
      })
    end

    members.sort_by! { |item| -item[:members] }
    chatroom_total_stats.sort_by! { |item| -item[:members] }

    Slim::Engine.set_options :pretty => true, :sort_attrs => false
    file = Slim::Template.new('app/views/message_stat.slim').render(
      Object.new,
      start_date: @start_date,
      end_date: @end_date,
      total_days: @total_days,
      chatrooms: @chatrooms,    # 每日聊天室明细数据
      members: members,    # 聊天室的最新成员人数
      stats: chatroom_total_stats,
    )

    filename = 'result.html'
    File.open(filename, 'w') { |f| f.write(file) }
    puts "Result: #{'message_stat.html'}"
  end


  private
    def city_chatrooms!
      Rails.cache.fetch(CITY_CHATROOMS_KEY) do
        chatrooms = {}
        Qyer::Chatroom.all.each do |c|
          # 艾普罗菲尔，穷游办公室
          next if ["53ba02e7144452cd76000004", "547eb6811444529ad8000091"].include?c.im_topic_id

          chatrooms[c.im_topic_id] = {
            id: c.id,
            name: c.chatroom_name,
            messages: [],
            registers: [],
          }
        end
        chatrooms
      end
    end

    def chatroom_max_members(limit)
      begin
        im_hottest_chatroom_url = "http://api.im.qyer.com/v1/im/topics/query.json"
        im_hottest_chatroom_url_params = {
          key: JK_KEY,
          type: 'party',
          limit: limit,
        }

        Rails.cache.fetch("chatroom_hottest_count") do
          r = RestClient.get im_hottest_chatroom_url, params: im_hottest_chatroom_url_params
          MultiJson.load r
        end

      rescue => e
        puts " -> #{e.backtrace.join("\n")}"
        e.message
      end
    end

    def zipfile(input, output)
      FileUtils.rm_f output if File.exist?output

      folder =  File.dirname(__FILE__)
      input_filenames = Dir.glob("#{folder}/bootstrap/*")

      Zip::File.open(output, Zip::File::CREATE) do |zipfile|
        input_filenames.each do |filename|
          zipfile.add(File.join('bootstrap', File.basename(filename)), filename)
        end
        zipfile.add(input, File.join(folder, input))
      end

      puts " Zip: #{output}"
    end
end
