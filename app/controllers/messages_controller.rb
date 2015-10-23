class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @messages = Message.order('timestamp DESC').page(params[:page])
  end

  def image
    @message = Message.find(params[:id])
    send_data Base64.decode64(@message.file), type: 'image/png', disposition: 'inline'
  end
end
