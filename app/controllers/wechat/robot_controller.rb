class Wechat::RobotController < ApplicationController
  @@token = "63da844381a4dfa25d76a4d0c0b9925d".freeze

  def show
    signature_data = [@@token, params[:timestamp], params[:nonce]].sort.join
    current_signature = Digest::SHA1.hexdigest(signature_data)

<<<<<<< HEAD
		if current_signature == params[:signature]
    	render text: params[:echostr]
		else
			render json: []
		end
=======
    render json: {
      pass: current_signature == params[:signature]
    }
>>>>>>> 656500774c546f5c61613ca56dae158f15cf204c
  end

  def create
  end
end
