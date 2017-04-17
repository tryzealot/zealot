class CarLicense
  URL = 'https://api.accident.zhongchebaolian.com/industryguild_mobile_standard_self2.1.2/mobile/standard/'.freeze
  USER_AGENT = {
    webview: 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14E304',
    login: 'BeiJingJiaoJing/201703102011 CFNetwork/811.4.18 Darwin/16.5.0',
    app: 'BeiJingJiaoJing/2.0.0 (iPhone; iOS 10.3; Scale/3.00)'
  }

  def initialize

  end

  def get_image_code(phone)
    url = build_uri('imageCheckCode')
    params = { phone: phone }
    headers = {
      'Accept' => 'image/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-language' => 'zh-cn',
      'User-Agent' => USER_AGENT[:login]
    }

    RestClient.get(url, params: params, headers: headers)
  end

  def send_phone_code(phone, image_code, flag = '01')
    url = build_uri('checkImageVerification')
    params = { phone: phone, imagecode: image_code, smsflag: flag }
    headers = {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-language' => 'zh-cn',
      'Content-Type' => 'application/json',
      'User-Agent' => USER_AGENT[:app]
    }

    RestClient.post(url, params.to_json, headers)
  end

  private

  def build_uri(uri)
    File.join(URL, uri)
  end
end
