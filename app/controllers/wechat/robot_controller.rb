class Wechat::RobotController < WechatController
  def show
    render json: ["nothing show"]
  end

  def create
    @message = Wechat::Message.factory(request.raw_post)

    reply = if @message.MsgType == 'text'
              case @message.Content
              when 'guahao', '1', '挂号', '回龙观'
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

  def booking_link
    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content          = "一键直达预约 | 积水潭医院回龙观\nhttps://wechat.benmu-health.com/wechat/register/index.html#!/selectResource?firstDeptCode=m_FCK_bd926ff4&firstDeptId=3582&firstDeptName=%E5%A6%87%E4%BA%A7%E7%A7%91&hosCode=H1136112&hosName=%E5%8C%97%E4%BA%AC%E7%A7%AF%E6%B0%B4%E6%BD%AD%E5%8C%BB%E9%99%A2%E5%9B%9E%E9%BE%99%E8%A7%82%E9%99%A2%E5%8C%BA&secondDeptCode=1012&secondDeptId=3532&secondDeptName=%E5%A6%87%E4%BA%A7%E7%A7%91%E9%97%A8%E8%AF%8A%E5%9B%9E%E9%BE%99%E8%A7%82"

    reply
  end

  def default_reply
    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = @message.ToUserName
    reply.ToUserName   = @message.FromUserName
    reply.Content      = "我还没有那么智能，请耐心等待手动回复 :P"
    reply
  end
end
