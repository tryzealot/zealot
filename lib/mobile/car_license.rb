require 'securerandom'

class CarLicense
  URL = 'https://api.accident.zhongchebaolian.com/industryguild_mobile_standard_self2.1.2/mobile/standard/'.freeze
  USER_AGENT = {
    webview: 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14E304',
    login: 'BeiJingJiaoJing/201703102011 CFNetwork/811.4.18 Darwin/16.5.0',
    app: 'BeiJingJiaoJing/2.0.0 (iPhone; iOS 10.3; Scale/3.00)'
  }

  def get_image_code(phone)
    url = build_uri('imageCheckCode')
    params = { phone: phone }
    headers = {
      accept: 'image/*;q=0.8',
      user_agent: USER_AGENT[:login]
    }

    HTTP.headers(headers)
        .get(url, params: params)
  end

  def send_phone_code(phone, image_code, flag = '01')
    url = build_uri('checkImageVerification')
    params = { phone: phone, imagecode: image_code, smsflag: flag }
    HTTP.headers(user_agent: USER_AGENT[:app])
        .post(url, json: params)
  end

  def login(phone, code, options = {})
    url = build_uri('login')
    location = random_location
    params = {
      phone: phone,
      valicode: code,

      appkey: '0791682354',
      citycode: '1101',

      deviceid: SecureRandom.hex(20),
      lat: location[:lat],
      lon: location[:lon],
      timestamp: Time.now.strftime('%F %T'),

      devicetype: 0,
      source: 0,
      vertype: 1,
      token: '',
    }.merge!(options)

    HTTP.headers(user_agent: USER_AGENT[:app])
        .post(url, json: params)
  end

  private

  def build_uri(uri)
    File.join(URL, uri)
  end

  def random_location
    rd = Random.new
    {
      lat: rd.rand(37.838498..41.867996).round(6),
      lon: rd.rand(113.847955..117.649224).round(6)
    }
  end
end
