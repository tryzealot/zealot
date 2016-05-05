class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def image
    @message = Message.find(params[:id])
    send_data Base64.decode64(@message.file), type: 'image/png', disposition: 'inline'
  end

  def destroy
    @message = Message.find(params[:id])
    if @message
      url = 'http://api.im.qyer.com/v1/im/history/remove.json'
      params = {
        key: '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
        msg_ids: @message.im_id
      }

      r = RestClient.post url, params
      data = JSON.parse(r)
      if data['meta']['code'] == 200
        @message.is_deleted = 1
        @message.save

        flash[:notice] = '聊天记录已被删除'
      else

        flash[:notice] = '删除失败，原因：'
      end

      redirect_to controller: :groups, action: :messages
    else
      flash[:error] = '未找到该消息'
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
    end
  end
end
