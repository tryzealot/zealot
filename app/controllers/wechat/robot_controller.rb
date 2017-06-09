class Wechat::RobotController < ApplicationController
  @@token = "63da844381a4dfa25d76a4d0c0b9925d".freeze

  def show
    signature_data = [@@token, params[:timestamp], params[:nonce]].sort.join
    current_signature = Digest::SHA1.hexdigest(signature_data)

    render json: {
      pass: current_signature == params[:signature]
    }
  end

  def create
  end
end
