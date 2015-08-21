class Api::V1::Demo::DayroutesController < Api::ApplicationController

  def show
    @uid = params.fetch 'uid', 1357827
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @lon, @lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
    @lat.strip!
    @lon.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ?
      DateTime.parse(@today + " +08:00") : DateTime.new(@today.year, @today.month, @today.day, 7, 0, 0, '+8')
    @route = params.fetch :route, 1

    query = {
      lat: @lat,
      lng: @lon,
      local_time: @today.to_i,
      device_id: @device_id,
      uid: @uid,
      route: @route
    }

    tour_status, tour_data = ra_show_daytour(query)
    logger.debug "data: #{tour_data}"
    status = tour_status ? 200 : 409
    render json: tour_data, status: status
  end


  def traffic
    params.delete :action
    params.delete :controller

    status, data = ra_traffic_between_two_pois(params)
    render json: data, status: status ? 200 : 409
  end

  private
    ##
    # RA 接口：两点交通查询
    #
    def ra_traffic_between_two_pois(params)
      url = 'http://doraemon.qyer.com/poi/p2p_traffic'
      http_request('get', url, params) do |json|
        if json[:status] == 'success'
          [true, json[:data]]
        else
          [false, { error: json[:msg] }]
        end
      end
    end

    ##
    # RA 接口：每日行程推荐
    #
    def ra_show_daytour(params)
      url = 'http://doraemon.qyer.com/recommend/onroad/daytours'
      key = "#{params[:device_id]}-#{Time.at(params[:local_time]).strftime("%Y%m%d")}"

      now = Time.at(params[:local_time]).to_datetime
      expires_date = DateTime.new(now.year, now.month, now.day, 23, 59, 59, '+08:00')
      expires_in = (expires_date.hour - now.hour).hours
      logger.debug "Daytour cache key: #{key} and expires in #{expires_in/60/60} hours"
      logger.debug "RA data read from cache!" if Rails.cache.exist?key

      Rails.cache.fetch(key, expires_in: expires_in) do
        http_request('get', url, params) do |json|
          if json[:status] == 'success'
            [true, json[:data]]
          else
            [false, { error: json[:msg] }]
          end
        end
      end
    end

    ##
    # 封装网络请求接口
    #
    def http_request(method, url, params)
      status = false
      data = []

      logger.debug "Request ra api: #{url}?#{params.to_query}"
      begin
        if method == 'get'
          r = RestClient.get url, params: params
        else
          r = RestClient.post url, params
        end

        if r.code == 200
          json = MultiJson.load r, symbolize_keys: true
          logger.debug "RA response: #{json}"
          if block_given?
            status, data = yield(json)
          else
            status = true
            data = json
          end
        end
      rescue Exception => e
        logger.fatal "RA error: #{e.message}"
        logger.fatal e.backtrace.join("\n")

        data = e
      end

      [status, data]
    end

end
