require 'zip'

class DiscussStatsJob < ActiveJob::Base
  queue_as :default

  CITY_DISCUSS_KEY = 'im_discuss'.freeze
  JK_KEY = '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx'.freeze

  IM_SERVER = '23.91.98.3'.freeze
  IM_USER = 'root'.freeze
  IM_PWD = 'im.server!QAZ@WSX'.freeze
  IM_PORT = 2233

  def perform(start_date, end_date)
    Rails.cache.clear

    discuss_total_stats = []
    @discusses = get_discusses!
    @start_date = Chronic.parse((start_date || 'yesterday') + ' 0:00')
    @end_date = Chronic.parse((end_date || 'today') + ' 23:59')
    @total_days = end_date.to_datetime.mjd - start_date.to_datetime.mjd

    Rails.logger.fatal "#{@start_date} - #{@end_date}"

    ###################################
    Rails.logger.fatal " * Connecting im server(#{IM_SERVER})..."
    ###################################
    discuss_ids = @discusses.keys

    Net::SSH.start(IM_SERVER, IM_USER, password: IM_PWD, port: IM_PORT) do |ssh|
      current_date = @start_date.to_date
      until @end_date.to_date < current_date
        start_timestamp = current_date.to_time.to_i * 1000

        Rails.logger.fatal " -> #{current_date}"
        Rails.logger.fatal "    Fetching discuss messages total: [#{start_timestamp}]"

        message_count_key = "discuss_message_count_#{start_timestamp}"
        date_messages = Rails.cache.fetch(message_count_key) do
          JSON.parse(ssh.exec!([
            '/opt/arrownock/db-scripts/get_chat_room_message_count.sh',
            JK_KEY,
            start_timestamp.to_s
          ].join(' ')))
        end

        date_messages.each do |topic_id, item|
          next unless discuss_ids.include?topic_id

          @discusses[topic_id][:messages].append({
            date: current_date.strftime('%Y%m%d'),
            messages: {
              topic: item['topic'].to_i,
              notice: item['notice'].to_i,
              total: item['topic'].to_i + item['notice'].to_i
            }
          })
        end

        Rails.logger.fatal '    Fetching discuss register total'
        register_count_key = "discuss_register_count_#{start_timestamp}"
        date_registers = Rails.cache.fetch(register_count_key) do
          JSON.parse(ssh.exec!([
            '/opt/arrownock/db-scripts/get_chat_room_new_uesr_count.sh',
            JK_KEY,
            start_timestamp.to_s
          ].join(' ')))
        end

        date_registers.each do |topic_id, value|
          next unless discuss_ids.include?topic_id

          @discusses[topic_id][:registers].append({
            date: current_date.strftime('%Y%m%d'),
            total: value
          })
        end

        current_date += 1

      end # /until
    end # /Net::SSH

    ###################################
    Rails.logger.fatal ' * Getting hottest discusss'
    ###################################
    members = []
    discusses_max_members = discuss_max_members(10_000_000)
    if discusses_max_members.is_a?Hash
      if discusses_max_members['meta']['code'] == 200
        discusses_max_members['response']['topics'].each do |item|
          members.append({
            discuss: item['name'],
            members: item['parties_count']
          })
        end
      else
        Rails.logger.fatal " -> Error: #{discusses_max_members}"
      end
    else
      Rails.logger.fatal " -> Error: #{discusses_max_members}"
    end

    Rails.logger.fatal ' * Fetching each discuss messages'
    @discusses.each do |_topic_id, discuss|
      message_total = 0
      discuss[:messages].each do |item|
        message_total += item[:messages][:total]
      end

      registers_total = 0
      discuss[:registers].each do |item|
        registers_total += item[:total]
      end

      members_total = 0
      members.each do |item|
        if item[:discuss] == discuss[:name]
          members_total = item[:members]
          break
        end
      end

      discuss_total_stats.append({
        discuss: discuss[:name],
        members: members_total,
        messages: message_total,
        average_message: (message_total / @total_days.to_f).round(2),
        registers: registers_total,
        average_register: (registers_total / @total_days.to_f).round(2)
      })
    end

    members.sort_by! { |item| -item[:members] }
    discuss_total_stats.sort_by! { |item| -item[:members] }

    Rails.cache.write 'datasource', @discusses

    Slim::Engine.set_options pretty: true, sort_attrs: false
    file = Slim::Template.new('app/views/discuss_stat.slim').render(
      Object.new,
      start_date: @start_date,
      end_date: @end_date,
      total_days: @total_days,
      chatrooms: @discusses, # 每日聊天室明细数据
      members: members, # 聊天室的最新成员人数
      stats: discuss_total_stats
    )

    filename = 'result.html'
    File.open(filename, 'w') { |f| f.write(file) }
    Rails.logger.fatal "Result: #{filename}"
  end

  private

  def get_discusses!
    Rails.cache.fetch(CITY_DISCUSS_KEY) do
      discusses = {}
      Qyer::Discuss.all.each do |c|
        discusses[c.chatroom_id] = {
          id: c.chatroom_id,
          name: c.group_name,
          messages: [],
          registers: []
        }
      end
      discusses
    end
  end

  def discuss_max_members(limit)
    im_hottest_discuss_url = 'http://api.im.qyer.com/v1/im/topics/query.json'
    im_hottest_discuss_url_params = {
      key: JK_KEY,
      type: 'party',
      limit: limit
    }

    Rails.cache.fetch('discuss_hottest_count') do
      r = RestClient.get im_hottest_discuss_url, params: im_hottest_discuss_url_params
      JSON.parse r
    end

  rescue => e
    Rails.logger.fatal " -> #{e.backtrace.join("\n")}"
    e.message
  end

  def zipfile(input, output)
    FileUtils.rm_f output if File.exist?output

    folder = File.dirname(__FILE__)
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
