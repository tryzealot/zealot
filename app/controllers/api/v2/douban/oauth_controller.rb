class Api::V2::Douban::OauthController < ActionController::API
  def create
    query = {
      '_v' => '1467',
      '_sig' => 'icyleaf_e6aVrrloMWTmXt4uJUxZ6Qq2PPc',
      '_ts' => Time.now.to_i,
      'alt' => 'json',
      'event_loc_id' => '108288',
      'loc_id' => '108288',
      'client_id' => '0ab215a8b1977939201640fa14c66bab',
      'client_secret' => '22b2cf86ccc81009',
      'grant_type' => 'password',
      'redirect_uri' => 'http%3A//frodo.douban.com',
      'douban_udid' => 'cce3e9c0d9a908af10362c3ee77f759272e107d5',
      'apikey' => '0ab215a8b1977939201640fa14c66bab',
      'username' => params['username'],
      'password' => params['password'],
    }

    url = 'https://frodo.douban.com/service/auth2/token'
    r = HTTP.headers({
      user_agent: 'api-client/0.1.3 com.douban.frodo/4.15.1 iOS/10.3.1 iPhone7,1',
#      content_type: 'application/x-www-form-urlencoded'
      }).post(url, form: query)
    render json: {
      request: {
        url: url,
        query: query,
        raw: query.to_query
      },
      response: JSON.parse(r)
    }
  end
end