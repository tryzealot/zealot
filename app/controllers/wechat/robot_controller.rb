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
    reply.Title        = "积水潭医院回龙观"
    reply.Description  = "一键直达预约挂号页面"
    reply.Content          = "一键直达预约 | 积水潭医院回龙观\nhttps://wechat.benmu-health.com/wechat/register/index.html"

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
