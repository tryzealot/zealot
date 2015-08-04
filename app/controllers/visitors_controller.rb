class VisitorsController < ApplicationController
  # before_filter :authenticate_user!

  def index
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end

  def wechat

  end

  def feed
    json = [
      {
        type: "thread",
        id: 1235,
        views: 9028613,
        title: "【摄影小赛】穷游摄影小赛之痴迷－－发美图写点评，Gopro等你拿！",
        photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
        url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
      },
      {
        type: "threads",
        tips: "去冲绳，就靠这些干货贴，省力省时间",
        entry: [
          {
            id: 120931,
            title: "【蓝色变奏曲】希腊，路过你的神话和童话 （6月希腊形势 千张美图 雅典 米克诺斯 圣托里尼 旅拍写真攻略 完结）",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          },
          {
            id: 120931,
            title: "微笑的印度洋眼泪，7日锡兰行（附超实用防骗防病攻略，非美图，纯干货已完结）",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          },
          {
            id: 120931,
            title: "摄影流，转接控，光怪陆离的巴塞罗纳不完全拆解穷游er访谈 | 小池：从丝路到前线",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
            url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
          }
        ]
      },
      {
        type: "discount",
        id: 120931,
        title: "微笑的印度洋眼泪，7日锡兰行（附超实用防骗防病攻略，非美图，纯干货已完结）",
        price: "1999元",
        tips: "超值特惠，还有机会"
      },
      {
        type: "discounts",
        tips: "去冲绳，不能错过的超低折扣",
        entry: [
          {
             title: "自由行",
             type: "free_trip",
             price: "2299元起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
             title: "机票",
             type: "flight",
             price: "1699元起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
             title: "当地活动",
             type: "event",
             price: "99元起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
             title: "酒店",
             type: "hotel",
             price: "3折起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
             title: "租车",
             type: "car",
             price: "99元起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
             title: "签证",
             type: "visa",
             price: "19元起",
             photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          }
        ]
      },
      {
        type: "city",
        id: 120931,
        cnname: "冲绳",
        enname: "Okinawa",
        tips: "足迹相同的小伙伴正在计划"
      },
      {
        type: "country",
        id: 120931,
        cnname: "捷克",
        enname: "Czech Republic",
        tips: "你可能喜欢的国家"
      },
      {
        type: "pois",
        tips: "去冲绳，快来点评它们",
        entry: [
          {
            id: 238917,
            cnname: "冲绳美丽海水族馆",
            enname: "Okinawa Churaumi Aquarium",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
            id: 238917,
            cnname: "万座毛",
            enname: "Manzamō",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          },
          {
            id: 238917,
            cnname: "波上宫",
            enname: "Naminouegu",
            photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400"
          }
        ]
      },
      {
        type: "ask",
        id: 120931,
        title: "美签面试不带护照可以吗？",
        description: "我的护照在加拿大领馆里，美签面试的时候不一定能拿到，如果只凭DS160和预约确认是否能面试？最好的可能是VO发给221G让我补护照，是吗？最坏的打算是根本不让面试，重新约时间。不知道有没有人有过类似的经历？穷的连护照都给不起。",
        tips: "如果你知道，快来帮帮TA"
      },
      {
        type: "mguide",
        id: 120931,
        title: "哈利波特电影系列之《哈利波特与魔法石》巡礼",
        description: "这里总结了哈利波特电影系列的第一部《哈利波特与魔法石》的一些景点。这些景点有的是第一部特有的，有的在后面的哈利波特电影中也有出现。当然还有一些场景没有列在里面，比如位于伦敦的澳大利亚官邸Austrialia House（古灵阁巫师银行的场景是在这座建筑的展示大厅里拍摄的）和哈罗公学（弗立维教授上课的课堂在这里拍摄）这两个地方都是不方便或者无法参观的。",
        tips: "关于英国的主题推荐"
      },
      {
        type: "forum",
        id: 120931,
        title: "境外购物",
        description: "喜刷刷喜刷刷",
        count: "3823个主题",
        tips: "进来看看，你有买买买的资质"
      },
      {
        type: "web",
        photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
        url: "http://appview.qyer.com/bbs/thread-1093464-1.html"
      }
    ]

    return render json: json, status: 200
  end
end
