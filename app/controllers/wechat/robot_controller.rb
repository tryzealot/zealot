class Wechat::RobotController < WechatController
  def show
    render json: ["nothing show"]
  end

  def create
    message = Wechat::Message.factory(request.raw_post)

    reply = Wechat::TextReplyMessage.new
    reply.FromUserName = message.ToUserName
    reply.ToUserName   = message.FromUserName
    reply.Content      = "我还没有那么智能，请耐心等待手动回复 :P"

    logger.info "Respone: #{reply.to_xml}"

    render plain: reply.to_xml
  end
end
