require 'health_client'

class Wechat::RobotController < WechatController
  before_action :set_client, only: [ :create ]

  def show
    render json: ["nothing show"]
  end

  def create
    @message = Wechat::Message.factory(request.raw_post)

    reply = if @message.MsgType == 'text'
              case @message.Content
              when '1'
                hospital_booking_help
              when '11'
                hospitals
              when 'g', '挂号', 'guahao'
                booking_link
              else
                default_reply
              end
            else
              default_reply
            end

    logger.info reply.to_xml

    render plain: reply.to_xml
  end

  private

  def hospital_booking_help
    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content      = "11. 医院列表查询\n12. 医院科室查询\n13. 医院科室一周预约情况"
    reply
  end

  def hospitals
    hospitals = Rails.cache.fetch("benmu_health_hospitals", expires_in: 1.day) do
      r = @client.hospitals
      data = JSON.parse(r.body)
      data['data']['hospitals']
    end

    content = ['当前开通的医院：']
    hospitals.each do |hospital|
      content.push("#{hospital["countyName"]} | #{hospital["hosName"]} #{hospital["hosLevel"]}")
    end

    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content      = content.join("\n")
    reply
  end

  def booking_link
    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content      = "https://wechat.benmu-health.com/wechat/register/index.html#!/selectResource?firstDeptCode=m_FCK_bd926ff4&firstDeptId=3582&firstDeptName=%E5%A6%87%E4%BA%A7%E7%A7%91&hosCode=H1136112&hosName=%E5%8C%97%E4%BA%AC%E7%A7%AF%E6%B0%B4%E6%BD%AD%E5%8C%BB%E9%99%A2%E5%9B%9E%E9%BE%99%E8%A7%82%E9%99%A2%E5%8C%BA&secondDeptCode=1012&secondDeptId=3532&secondDeptName=%E5%A6%87%E4%BA%A7%E7%A7%91%E9%97%A8%E8%AF%8A%E5%9B%9E%E9%BE%99%E8%A7%82\n ↑ ↑ ↑ ↑ ↑ ↑ ↑\n一键直达预约 | 积水潭医院回龙观"
    reply
  end

  def default_reply
    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content      = "万事屋目前可提供如下服务：\n1. 北京医院挂号\n\n其他服务请留言联系 :P"
    reply
  end

  def set_client
    @client = HealthClient.new('__jsluid=bd5ae0fc289eac8c6848238469f89d3b; _ucp=QPrYUv5YZ1zVd5ha3tBVB0cdWXr57osValPqwdLNdyUIACuJQzm9EHiC6KWfOUI8vvwFVQ..; _lgd=1')
  end
end
