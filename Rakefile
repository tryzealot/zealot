# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
load 'tasks/emoji.rake'

Rails.application.load_tasks


desc "更新 app key"
task :update_app_key => :environment do
  App.all.each do |app|
    app.key = Digest::MD5.hexdigest(SecureRandom.uuid + app.identifier)
    app.save!
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

namespace :udp do
  task :server => :environment  do
    require 'socket'

    server = UDPSocket.new
    server.bind '127.0.0.1', 44444

    loop do
      data, addr = server.recvfrom(1024)
      puts "Time is #{Time.now}"
      puts "Data: #{data}"

      server.send "data: [#{data}] recived!", 0, addr[3], addr[1]
    end

    server.close
  end

  task :client do
    s = UDPSocket.new

    loop do
      print "> "
      data = STDIN.gets.chomp
      s.send(data, 0, '127.0.0.1', 44443)
      if data == "/quit"
        break
      end
    end

    s.close
  end
end

namespace :tcp do
  task :server do
    s = TCPServer.new 44444
    puts "Server started: http://127.0.0.1:44444"

    loop do
      c = s.accept
      msg = c.gets.chomp!
      puts "[Client] #{msg}"
      c.puts "[#{Time.now}] Hello !"
    end
  end
end

namespace :faye do

  task :rethinkdb do
    require "rethinkdb"
    include RethinkDB::Shortcuts

    conn = r.connect host: "192.168.99.100", port: 28015
    puts "Service starting with RethinkDB"
    EM.run do
      r.table("logs").changes.em_run(conn) do |err, change|
        puts change
      end
    end
  end

  task :server do
    # require 'faye'

    endpoint = "http://localhost:8087/"
    proxy    = {:headers => {'User-Agent' => 'Faye'}}
    puts "Connecting to #{endpoint}"

    EM.run {
      client = Faye::Client.new(endpoint, :proxy => proxy)
      client.add_websocket_extension(PermessageDeflate)

      subscription = client.subscribe '/chat/*' do |message|
        user = message['user']

        publication = client.publish("/members/#{ user }", {
          "user"    => "ruby-logger",
          "message" => "Got your message, #{ user }!"
        })
        publication.callback do
          puts "[PUBLISH SUCCEEDED]"
        end
        publication.errback do |error|
          puts "[PUBLISH FAILED] #{error.inspect}"
        end
      end

      subscription.callback do
        puts "[SUBSCRIBE SUCCEEDED]"
      end
      subscription.errback do |error|
        puts "[SUBSCRIBE FAILED] #{error.inspect}"
      end

      client.bind 'transport:down' do
        puts "[CONNECTION DOWN]"
      end
      client.bind 'transport:up' do
        puts "[CONNECTION UP]"
      end
    }
  end
end

