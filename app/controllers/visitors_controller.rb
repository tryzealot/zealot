class VisitorsController < ApplicationController
  # before_filter :authenticate_user!

  def index
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end

  def web(index:0)
    [
      {
        type: "web",
        photo: "http://pic.qyer.com/public/mobileapp/appsubject/2015/07/30/14382382013673/600x400",
        url: "http://appview.qyer.com/bbs/thread-1093464-1.html"
      }
    ]
  end

  def threads(index:0)
    [
      {
        type: "threads",
        tips: "去冲绳，就靠这些干货贴，省力省时间",
        entry: [
          {
            id: 120931,
            title: "【蓝色变奏曲】希腊，路过你的神话和童话 （6月希腊形势 千张美图 雅典 米克诺斯 圣托里尼 旅拍写真攻略 完结）",
            photo: "http://pic.qyer.com/album/user/1230/33/QEtWQhkEZU0/index/300x300",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          },
          {
            id: 120931,
            title: "微笑的印度洋眼泪，7日锡兰行（附超实用防骗防病攻略，非美图，纯干货已完结）",
            photo: "http://pic.qyer.com/album/user/1195/17/QEhcRxsAZk4/index/300x300",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          },
          {
            id: 120931,
            title: "摄影流，转接控，光怪陆离的巴塞罗纳不完全拆解穷游er访谈 | 小池：从丝路到前线",
            photo: "http://pic.qyer.com/album/user/1109/49/QEhVSx4OYU0/index/300x300",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          }
        ]
      }
    ]
  end

  def forum(index:0)
    [
      {
        type: "forum",
        id: 100,
        title: "境外购物",
        description: "喜刷刷喜刷刷",
        photo: "http://pic.qyer.com/icon/bbs/forums/100",
        count: "3823个主题",
        tips: "进来看看，你有买买买的资质"
      }
    ]
  end

  def mguide(index:0)
    [
      {
        type: "mguide",
        id: 2193,
        title: "那片最蓝的海——冲绳潜水指南",
        photo: "http://pic.qyer.com/album/user/992/12/SEBXQxgFaQ/index/600x400",
        description: "冲绳的海是全世界潜水爱好者向往的地方。作为是日本唯一的亚热带县，环绕各个岛屿的大海，是全世界有名的潜水景点，一年四季都吸引着世界各地的潜水爱好者。超群的透明度，种类繁多的珊瑚礁，五彩缤纷的鱼群，除了这些自然条件的优势，冲绳还具备有资格的教练、知识丰富的讲解员、最新的潜水用品、完备的交通设施和医疗设施，让你在冲绳能够舒适、愉快、安全地享受潜水的乐趣。没有潜水执照的初学者也可以放心，潜水教练同行的“体验型潜水”也绝对不会让你错过那片最美的海底世界。",
        tips: "关于冲绳的主题推荐"
      }
    ]
  end

  def thread(index:0)
    [
      {
        type: "thread",
        id: 1098352,
        views: 9028613,
        title: "【摄影小赛】穷游摄影小赛之痴迷－－发美图写点评，Gopro等你拿！",
        photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
        url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
      }
    ]
  end

  def discount(index:0)
    [
      {
        type: "discount",
        id: 50072,
        title: "上海直飞福冈5天往返含税机票（含9.3小长假）",
        photo: "http://pic.qyer.com/public/picstock/2014/09/12/14105211358998/600x400",
        price: "1999元",
        tips: "超值特惠，还有机会"
      }
    ]
  end

  def city(index:0)
    [
      {
        type: "city",
        id: 8603,
        cnname: "大阪",
        enname: "Osaka",
        photo: "http://pic.qyer.com/album/user/387/88/QkFSShIHaQ/index/600x400",
        tips: "足迹相同的小伙伴正在计划"
      }
    ]
  end

  def country(index:0)
    [
      {
        type: "country",
        id: 182,
        cnname: "西班牙",
        enname: "Spain",
        photo: "http://pic.qyer.com/album/100/0e/1853557/index/600x400",
        tips: "你可能喜欢的国家"
      }
    ]
  end

  def pois(index:0)
    [
      {
        type: "pois",
        tips: "去冲绳，快来点评它们",
        entry: [
          {
            id: 238917,
            cnname: "冲绳美丽海水族馆",
            enname: "Okinawa Churaumi Aquarium",
            photo: "http://pic.qyer.com/album/user/632/9/R0pXQhMAYw/index/640"
          },
          {
            id: 238917,
            cnname: "万座毛",
            enname: "Manzamō",
            photo: "http://pic.qyer.com/album/user/324/93/QktRSxkOZQ/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫1",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫2",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫3",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫4",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫5",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          },
          {
            id: 238917,
            cnname: "波上宫6",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/747/37/Rk1SQR0CaA/index/640"
          }
        ]
      }
    ]
  end

  def discounts(index:0)
    [
      {
        type: "discounts",
        tips: "去冲绳，不能错过的超低折扣",
        entry: [
          {
             id: 50055,
             title: "自由行",
             type: "free_trip",
             price: "2299元起",
             photo: "http://pic.qyer.com/public/lastmin/lastminute/2015/08/03/14386028138913/300_200"
          },
          {
             id: 50055,
             title: "机票",
             type: "flight",
             price: "1699元起",
             photo: "http://pic.qyer.com/lastminute/library/2014/12/26/1419565579/300_200"
          },
          {
             id: 50055,
             title: "当地活动",
             type: "event",
             price: "99元起",
             photo: "http://pic.qyer.com/public/supplier/lastminute/2015/05/11/14313398323320/300_200"
          },
          {
             id: 50055,
             title: "酒店",
             type: "hotel",
             price: "3折起",
             photo: "http://pic.qyer.com/public/supplier/lastminute/2015/08/03/14385967053481/300_200"
          },
          {
             id: 50055,
             title: "租车",
             type: "car",
             price: "99元起",
             photo: "http://pic.qyer.com/public/supplier/lastminute/2015/07/27/14379924869731/300_200"
          },
          {
             id: 50055,
             title: "签证",
             type: "visa",
             price: "19元起",
             photo: "http://pic.qyer.com/public/lastmin/lastminute/2014/11/06/14152545639286/300_200"
          }
        ]
      }
    ]
  end

  def ask(index:0)
    [
      {
        type: "ask",
        id: 879422,
        title: "关于波兰Krakow Pass",
        user_id: 2361080,
        avatar: "http://static.qyer.com/data/avatar/002/36/10/80_avatar_big.jpg?v=1427726474",
        description: "下星期出发去krakow。要去k三天半，计划一天去盐矿，一天去集中营，剩下的一天逛老城区。酒店订在距离老城区2.3公里的地方，酒店楼下就有电车站。在网站查了一下城市交通卡，有3天和2天的选择，分别需要120pln和100pln.有没有哪位小伙伴买过这个卡，到底划不划算？还是单独买各种交通票？",
        tips: "如果你知道，快来帮帮TA"
      },
    ]
  end

  def feed
    page = params.fetch(:page, 1).to_i
    count = params.fetch(:count, 10).to_i

    types = %w[thread discount forum mguide web city country ask discounts threads pois]

    data = []
    if page <= 50
      count.times do |i|
        type = types[rand(types.count)]
        item = self.send(type.to_sym)
        data.push(item[rand(item.count)])
      end
    end

    # max_page = json.count / count
    # max_page += 1 if json.count % count != 0
    #
    # start_index = (page - 1) * count
    # end_index = start_index + count - 1
    #
    # data = json[start_index..end_index] ? json[start_index..end_index] : []

    return render json: {
      status: 1,
      info: "",
      times: 0,
      # start: start_index,
      # end: end_index,
      data: data
    }, status: 200
  end
end
