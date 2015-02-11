module AppHelper

  def qr_code(content, options = {})
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
      text: content
    }

    image_tag api_url + "?" + api_query.to_query
  end

end
