class Apps::QrcodeController < AppsController
  before_action :set_app

  ##
  # 显示应用的二维码
  # GET /apps/:slug/(:version)/qrcode
  def index
    render qrcode: qrcode_url,
           module_px_size: qrcode_size,
           fill: '#F4F5F6',
           color: '#465960'
  end

  private

  def qrcode_url
    if params[:version]
      url_for(@app) + "/#{params[:version]}/qrcode"
    else
      url_for(@app) + "/qrcode"
    end
  end

  def qrcode_size
    case params[:size]
    when 'medium'
      4
    when 'large'
      6
    else
      2
    end
  end
end
