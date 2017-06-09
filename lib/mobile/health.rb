module Health
  URL = 'https://wechat.benmu-health.com/mobile/wx/product'
  USER_AGENT = 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14E304 MicroMessenger/6.5.8 NetType/WIFI Language/zh_CN'.freeze

  class Client
    def initialize(cookie_string)
      @cookies = make_cookies(cookie_string)
    end

    def hospitals
      url = build_uri('hospitals')
      headers = {
        user_agent: USER_AGENT
      }

      HTTP.cookies(@cookies)
          .headers(headers)
          .get(url)
    end

    def departments(hospital_id)
      url = build_uri('departments')
      headers = {
        user_agent: USER_AGENT
      }
      params = {
        'hosCode' => hospital_id,
        'CHANNEL' => 'wechat'
      }

      HTTP.cookies(@cookies)
          .headers(headers)
          .get(url, params: params)
    end

    private

    def make_cookies(cookie_string)
      cookie_string.split(';').each_with_object({}) do |argv, obj|
        key, value = argv.split('=')
        obj[key.strip] = value.strip
      end
    end

    def build_uri(uri)
      File.join(URL, uri)
    end
  end
end
