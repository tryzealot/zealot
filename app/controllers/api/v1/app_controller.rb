class Api::V1::AppController < Api::ApplicationController

  def upload
    @app = App.find_by(params[:identifier])
    if ! @app
      render json: {
        error: "App is missing"
      }
    else
      render json: @release
    end
  end

  def versions
    key = Digest::MD5.hexdigest('123445345')
    secret = Digest::SHA1.base64digest(key)[0..6]

    render json: {
      key: key,
      secret: secret
    }
  end

  def info

    render json: params

  end

  def install_url
    render json: params
  end

end
