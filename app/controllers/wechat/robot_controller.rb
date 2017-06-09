class Wechat::RobotController < WechatController
  def show
    render json: ["nothing show"]
  end

  def create
    logger.info params

    message = Wechat::TextReplyMessage.new
    message.FromUserName = "icyleaf"
    message.ToUserName   = params[:openid]
    message.Content      = "hello"

    render text: message.to_xml
  end
end
