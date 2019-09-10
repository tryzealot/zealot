class WechatController < ApplicationController
  TOKEN = '63da844381a4dfa25d76a4d0c0b9925d'.freeze

  before_action :signature_vaild?

  protected

  def signature_vaild?
    signature_data = [TOKEN, params[:timestamp], params[:nonce]].sort.join
    current_signature = Digest::SHA1.hexdigest(signature_data)

    raise ActionCable::Connection::Authorization::UnauthorizedError, 'unauthorized signature' if current_signature != params[:signature]

    return render text: params[:echostr] if params[:echostr]
  end
end
