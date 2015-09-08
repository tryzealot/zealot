module AppHelper

  def qr_code(url, options = {})
    # qrcode = RQRCode::QRCode.new(url, level: :h)
    # raw qrcode.as_svg(
    #   color: '465960',
    #   fill: 'F4F5F6',
    #   module_size: 7,
    #   offset: 15,
    # )

    m = options[:m] || 20
    bg = options[:bg] || 'f4f5f6'
    fg = options[:fg] || '475a62'
    el = options[:el] ||  'h'

    api_url = 'http://qr.liantu.com/api.php'
    api_query = {
      m: m,
      bg: bg,
      fg: fg,
      el: el,
      text: url
    }

    image_tag api_url + "?" + api_query.to_query
  end

end
