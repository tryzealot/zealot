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
      },
      {
        type: "web",
        photo: "http://pic.qyer.com/public/mobileapp/appsubject/2015/07/30/14382382013673/600x400",
        url: "http://appview.qyer.com/bbs/thread-1093464-1.html"
      },
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
      },
      {
        type: "forum",
        id: 120931,
        title: "境外购物",
        description: "喜刷刷喜刷刷",
        photo: "http://pic.qyer.com/icon/bbs/forums/100",
        count: "3823个主题",
        tips: "进来看看，你有买买买的资质"
      },
      {
        type: "mguide",
        id: 120931,
        title: "哈利波特电影系列之《哈利波特与魔法石》巡礼",
        photo: "http://pic.qyer.com/album/user/992/12/SEBXQxgFaQ/index/600x400",
        description: "这里总结了哈利波特电影系列的第一部《哈利波特与魔法石》的一些景点。这些景点有的是第一部特有的，有的在后面的哈利波特电影中也有出现。当然还有一些场景没有列在里面，比如位于伦敦的澳大利亚官邸Austrialia House（古灵阁巫师银行的场景是在这座建筑的展示大厅里拍摄的）和哈罗公学（弗立维教授上课的课堂在这里拍摄）这两个地方都是不方便或者无法参观的。",
        tips: "关于英国的主题推荐"
      },
      {
        type: "ask",
        id: 120931,
        title: "美签面试不带护照可以吗？",
        user_id: 2361080,
        avatar: "http://static.qyer.com/data/avatar/002/36/10/80_avatar_big.jpg?v=1427726474",
        description: "我的护照在加拿大领馆里，美签面试的时候不一定能拿到，如果只凭DS160和预约确认是否能面试？最好的可能是VO发给221G让我补护照，是吗？最坏的打算是根本不让面试，重新约时间。不知道有没有人有过类似的经历？穷的连护照都给不起。",
        tips: "如果你知道，快来帮帮TA"
      },
      {
        type: "thread",
        id: 1235,
        views: 9028613,
        title: "【摄影小赛】穷游摄影小赛之痴迷－－发美图写点评，Gopro等你拿！",
        photo: "http://pic.qyer.com/album/user/1005/3/QElVRxoEaU0/index/680x400",
        url: "http://appview.qyer.com/bbs/thread-1098352-1.html"
      },
      {
        type: "discount",
        id: 120931,
        title: "微笑的印度洋眼泪，7日锡兰行（附超实用防骗防病攻略，非美图，纯干货已完结）",
        photo: "http://pic.qyer.com/public/picstock/2014/09/12/14105211358998/600x400",
        price: "1999元",
        tips: "超值特惠，还有机会"
      },
      {
        type: "city",
        id: 120931,
        cnname: "冲绳",
        enname: "Okinawa",
        photo: "http://pic.qyer.com/album/user/863/66/SU9WRBwOYA/index/600x400",
        tips: "足迹相同的小伙伴正在计划"
      },
      {
        type: "country",
        id: 120931,
        cnname: "捷克",
        enname: "Czech Republic",
        photo: "http://pic.qyer.com/album/user/350/25/QkxVQB8GYw/index/600x400",
        tips: "你可能喜欢的国家"
      }
    ]

    return render json: {
      status: 1,
      info: "",
      times: 0,
      data: json
    }, status: 200
  end
end
