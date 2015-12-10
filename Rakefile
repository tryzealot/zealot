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
  type = {
    subject: {
      title: '分享了一个专题',
      value: 11,
    },
    poi: {
      title: '分享了一个旅行地',
      value: 8,
    }
  }

  # 专题
  # customData =  {
  #   "tipText": "重要播报",
  #   "content": "",
  #   "action": "share",
  #   "attribute5": 0,
  #   "fromUserName": "i打头的",
  #   "attribute4": 0,
  #   "title": "特别安全提醒，巴黎突发公布袭击",
  #   "fromUserAvatar": "http://static.qyer.com/data/avatar/001/35/78/27_avatar_big.jpg?v=1444731534",
  #   "type": 11,
  #   "photo": "http://pic.qyer.com/public/mobileapp/appzt/2015/11/14/14474760378222",
  #   "attribute1": "http://appview.qyer.com/op/zt/20151114.html"
  # }

  # 微锦囊
  # "customData": {
  #   "tipText": "刚刚分享了一个微锦囊",
  #   "content": "去年第三次第三次去泰国，按图索骥三天逛吃逛吃之旅，有游客去的地方，但大多数...",
  #   "action": "share",
  #   "attribute5": 0,
  #   "fromUserName": "i打头的",
  #   "attribute4": 0,
  #   "title": "呕心沥血推清迈美食",
  #   "wid": "795",
  #   "fromUserAvatar": "http://static.qyer.com/data/avatar/001/35/78/27_avatar_big.jpg?v=1444731534",
  #   "type": 8,
  #   "photo": "http://pic.qyer.com/album/user/389/89/QkFcShMBYA/index/710x360"
  # },

  # POI
  # "customData": {
  #   "tipText": "刚刚分享了一个微锦囊",
  #   "content": "去年第三次第三次去泰国，按图索骥三天逛吃逛吃之旅，有游客去的地方，但大多数...",
  #   "action": "share",
  #   "attribute5": 0,
  #   "fromUserName": "i打头的",
  #   "attribute4": 0,
  #   "title": "呕心沥血推清迈美食",
  #   "wid": "795",
  #   "fromUserAvatar": "http://static.qyer.com/data/avatar/001/35/78/27_avatar_big.jpg?v=1444731534",
  #   "type": 9,
  #   "photo": "http://pic.qyer.com/album/user/389/89/QkFcShMBYA/index/710x360"
  # },

  # 游记（帖子）
  # "customData": {
  #   "attribute4": 0,
  #   "fromUserName": "i打头的",
  #   "tipText": "刚刚分享了一篇游记",
  #   "attribute1": "http://appview.qyer.com/bbs/thread-1370016-1.html",
  #   "fromUserAvatar": "http://static.qyer.com/data/avatar/001/35/78/27_avatar_big.jpg?v=1444731534",
  #   "title": "尼泊尔之行：加德满都、博卡拉、阿纳...",
  #   "action": "share",
  #   "type": 5,
  #   "attribute5": 0,
  #   "wid": "1370016",
  #   "photo": "http://static.qyer.com/images/common/icon/114-2.png",
  #   "content": "meggiechen\n2015-09-16最后更新\n"
  # },

  user = {
    id: 4997295,
    im_id: 'AIMCUZ4FEBBMR9IF9P6YFHI',
    username: '穷游无线君',
    avatar: 'http://static.qyer.com/data/avatar/004/99/72/95_avatar_big.jpg?v=1439364189'
  }

  topic = {
    id: '55ebbb2d82a0d0cf3400a379',
    name: '巴黎'
  }

  url = 'http://api.im.qyer.com/v1/im/notice.json'
  custom_data =  {
    tipText: "重要播报",
    content: "",
    action: "share",
    attribute5: 0,
    fromUserName: user[:username],
    attribute4: 0,
    title: "巴黎突发恐怖袭击",
    fromUserAvatar: user[:avatar],
    type: 11,
    photo: "http://pic.qyer.com/public/mobileapp/appzt/2015/11/14/14474760378222",
    attribute1: "http://appview.qyer.com/op/zt/20151114.html"
  }
  # custom_data = {
  #   tipText: "有时间来我们这里转转！",
  #   content: "欢迎来坐坐！",
  #   action: "share",
  #   attribute5: 0,
  #   fromUserName: user[:username],
  #   attribute4: 0,
  #   title: "穷游清迈Q-Home",
  #   wid: "279953",
  #   type: 8,
  #   fromUserAvatar: user[:avatar],
  #   photo: "http://pic.qyer.com/album/user/1284/52/QEtdRh8FZEA/index/w800"
  # }

  params = {
    key: '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
    from: user[:im_id],
    topic: topic[:id],
    notice: 'SHARE_TO_CHATROOM',
    msg_id: SecureRandom.hex(10),
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

