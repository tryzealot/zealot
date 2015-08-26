class Api::V1::Demo::DayroutesController < Api::ApplicationController

  POI_CATEGORY = {
    '32' => '景点',
    '77' => '交通',
    '78' => '美食',
    '147' => '购物',
    '148' => '活动',
    '149' => '住宿',
  }

  TRIPMODE = {
    'default' => '步行（默认）',
    'walk' => '步行',
    'drive' => '自驾',
  }

  def show
    @uid = params.fetch 'uid', 1357827
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @lng, @lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
    @lat.strip!
    @lng.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ?
      DateTime.parse(@today + " +08:00") : DateTime.new(@today.year, @today.month, @today.day, 7, 0, 0, '+8')
    @route = params.fetch :route, 1

    query = {
      lat: @lat,
      lng: @lng,
      local_time: @today.to_i,
      device_id: @device_id,
      uid: @uid,
      route: @route
    }

    tour_status, tour_data = ra_show_daytour(query)
    ap tour_status
    ap tour_data

    data = if tour_status
      tours = []
      tour_data.each do |item|
        tours = item

        if item[:type] == 'poi'
          tours = parse_poi(@lat, @lng, item)
        else
          tours = parse_traffic(item)
        end
      end
    else
      tour_data
    end

    status = tour_status ? 200 : 409
    render json: data, status: status
  end

  def update
    tour_status, tour_data = ra_update_daytour(params)
    data = if status
      tours = []
      tour_data.each do |item|
        tours = item
        if item[:type] == 'poi'
          tours = parse_poi(@lat, @lng, item)
        else
          tours = parse_traffic(item)
        end
      end
    else
      tour_data
    end

    status = tour_status ? 200 : 409
    render json: data, status: status
  end

  def traffic
    params.delete :action
    params.delete :controller

    status, data = ra_traffic_between_two_pois(params)
    if status
      data = parse_traffic(data)
    end

    render json: data, status: status ? 200 : 409
  end

  def list_location
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + " +08:00") : @today

    key = "#{@device_id}-#{@today.strftime("%Y-%m-%d")}"
    # Rails.cache.delete cache_key
    @locations = Rails.cache.fetch(key) do
      []
    end
  end

  def upload_location
    key = "#{params[:device_id]}-#{params[:date]}"
    @locations = Rails.cache.fetch(key) do
      []
    end

    @locations.append(params)
    Rails.cache.write(key, @locations)

    status, data = ra_upload_location(params)
    render json: data
  end

  def clear_cache
    key = if params[:key]
      params[:key]
    else
      device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
      lng, lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
      lat.strip!
      lng.strip!
      today = params.fetch 'date', Time.now
      today = (today.is_a?String) ? DateTime.parse(today + " +08:00") : today
      route = params.fetch :route, 1

      cache_key(device_id, lat, lng, today, route)
    end

    logger.debug "Check cache key: #{key}"

    status, data = if Rails.cache.exist?key
      Rails.cache.delete(key)
      [200, { message: 'ok' }]
    else
      [404, { message: 'cache not found' }]
    end

    render json: data, status: status
  end

  private
    def parse_poi(lat, lng, data)
      arrival_time = Time.at(data[:arrival_time])
      now = Time.now
      data[:catename] = POI_CATEGORY[data[:cateid].to_s]
      data[:lat] = data[:geo][1]
      data[:lng] = data[:geo][0]
      data[:distance] = Haversine.distance(lat.to_f, lng.to_f, data[:lng], data[:lat]).to_kilometers.round(2)
      data[:arrival_time] = arrival_time.strftime('%H:%M')
      data[:duration] = (data[:duration] / 60).round
      data[:selected] = now > arrival_time ? false : true
    end

    def cache_key(device_id, lat, lng, time, route)
      time = time.strftime("%Y%m%d%H")
      hash = Digest::MD5.hexdigest([device_id, lng, lat].join('-')).upcase

      ap device_id
      ap lat
      ap lng

      [hash, time, route].join('-')
    end

    def parse_traffic(data)
      data[:mode] = TRIPMODE.has_key?(data[:tripmode].downcase) ? TRIPMODE[data[:tripmode].downcase] : data[:tripmode]
      data[:traffic_time] = (data[:traffic_time] / 60).round

      # if data[:segments] == '""'
      #   data[:segments] = []
      # else
      #   data[:segments] = MultiJson.load(data[:segments])
      # end

      data
    end

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

      key = cache_key(params[:device_id], params[:lat], params[:lng], Time.at(params[:local_time]), params[:route])

      now = Time.at(params[:local_time]).to_datetime
      expires_date = DateTime.new(now.year, now.month, now.day, 23, 59, 59, '+08:00')
      expires_in = (expires_date.hour - now.hour).hours
      logger.debug "Daytour cache key: #{key} and expires in #{expires_in/60/60} hours"

      cache_exist = Rails.cache.exist?(key)
      status, data = Rails.cache.fetch(key, expires_in: expires_in) do
        http_request('get', url, params) do |json|
          if json[:status] == 'success'
            [true, json[:data]]
          else
            [false, { error: json[:msg] }]
          end
        end
      end

      logger.debug "Cache data: #{data}" if cache_exist
      [status, data]
    end

    ##
    # RA 接口：删除 POI 并重新推荐线路
    #
    def ra_update_daytour(params)
      lng, lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
      lng.strip!
      lat.strip!
      query = {
        local_time: DateTime.parse(params[:date] + "+08:00").to_i,
        device_id: params[:device_id],
        lat: lat,
        lng: lng,
        uid: params[:uid],
        dislike_poiids: params[:dislike_poiids],
        route: params[:route]
      }
      url = 'http://doraemon.qyer.com/recommend/onroad/modify_route/'
      response = http_request('get', url, query) do |json|
        if json.is_a?(Hash) && json[:status] == 'success'
          [true, json[:data]]
        else
          [false, { error: json[:msg] }]
        end
      end

      key = cache_key(params[:device_id], params[:lat], params[:lng], Time.at(params[:local_time]), params[:route])

      now = Time.at(params[:local_time]).to_datetime
      expires_date = DateTime.new(now.year, now.month, now.day, 23, 59, 59, '+08:00')
      expires_in = (expires_date.hour - now.hour).hours
      logger.debug "Daytour cache key: #{key} and expires in #{expires_in/60/60} hours"
      if Rails.cache.exist?(key)
        Rails.cache.delete key
        logger.debug "Cache had been updated"
      end
      Rails.cache.write key, response

      response
    end


    def ra_upload_location(params)
      lng, lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
      lng.strip!
      lat.strip!

      query = {
        device_id: params[:device_id],
        local_time: DateTime.parse("#{params[:date]} #{params[:time]} +08:00").to_i,
        lat: lat,
        lng: lng,
        uid: 1357827,
      }

      url = 'http://doraemon.qyer.com/recommend/onroad/update_loc/'
      http_request('get', url, query)
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
