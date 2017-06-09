class Wechat::RobotController < WechatController
  def show
    render json: ["nothing show"]
  end

  def create
    logger.info params.to_h
    logger.info request.raw_post
    message = Wechat::TextReplyMessage.new
    message.FromUserName = "icyleaf"
    message.ToUserName   = params[:openid]
    message.Content      = "hello"

    render plain: message.to_xml
  end
end
