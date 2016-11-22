module AppsHelper
  def app_icon?(release, options = {})
    if release && release.icon && release.icon.file && release.icon.file.exists?
      size = options.delete(:size) || :thumb
      image_tag(release.icon_url(size), options)
    end
  end

  def qr_code(url)
    qrcode = RQRCode::QRCode.new(url, level: :h)
    raw qrcode.as_svg(
      color: '465960',
      fill: 'F4F5F6',
      module_size: 7,
      offset: 15
    )
  end

  def display_app_device(app)
    case app.device_type.downcase
    when 'ios'
      'iOS'
    when 'iphone'
      'iPhone'
    when 'ipad'
      'iPad'
    when 'android'
      'Android'
    else
      app.device_type
    end
  end
end
