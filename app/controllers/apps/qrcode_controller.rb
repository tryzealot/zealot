class Apps::QrcodeController < AppsController
  before_action :set_app

  ##
  # 显示应用的二维码
  # GET /apps/:slug/(:version)/qrcode
  def show
    render qrcode: app_detail_url,
           module_px_size: qrcode_size,
           fill: '#FFFFFF',
           color: '#465960'
  end

  private

  def app_detail_url
    url_for(@app) + "/#{params[:version]}"
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
