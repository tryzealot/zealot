class Api::V2::Licenses::LoginController < ActionController::API
  before_action :set_client

  # 获取登录图片验证码
  def show
    image = @client.get_image_code(params[:phone])
    send_data image, type: image.headers[:content_type], disposition: 'inline'
  end

  # 下发图片验证码
  def update
    r = @client.send_phone_code(params[:phone], params[:code])
    data = JSON.parse(r)
    case data['rescode']
    when '200'
      render json: {
        status_code: data['rescode'],
        message: data['resdes']
      }, status: :ok
    else
      render json: {
        status_code: data['rescode'],
        message: data['resdes']
      }, status: :bad_request
    end
    
    def
  end

  # 使用手机、验证码登录
  def create
    r = @client.login(params[:phone], params[:code])
    render json: JSON.parse(r)
  end

  private

  def set_client
    @client = CarLicense.new
  end
end
