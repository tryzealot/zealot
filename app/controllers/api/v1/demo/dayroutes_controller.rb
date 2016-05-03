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
    @lat, @lng = params.fetch('location', '22.3245866064,114.173473119').split(',')
    @lat.strip!
    @lng.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ?
      DateTime.parse(@today + " +08:00") : DateTime.new(@today.year, @today.month, @today.day, 7, 0, 0, '+8')
    @route = params.fetch :route, 1

    query = {
      lng: @lng,
      lat: @lat,
      local_time: @today.to_i,
      device_id: @device_id,
      uid: @uid,
      route: @route
    }

    status, data = ra_show_daytour(query)
    if status
      data[:entry].each_with_index do |item, i|
        data[:entry][i] = if item[:type] == 'poi'
          parse_poi(@lat, @lng, item)
        else
          parse_traffic(item)
        end
      end
    end

    status = status ? 200 : 409
    render json: data, status: status
  end

  def update
    status, data = ra_update_daytour(params)
    if status
      data[:entry].each_with_index do |item, i|
        data[:entry][i] = if item[:type] == 'poi'
          parse_poi(@lat, @lng, item)
        else
          parse_traffic(item)
        end
      end
    end

    status = status ? 200 : 409
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
      lat, lng = params.fetch('location', '22.3245866064,114.173473119').split(',')
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
      [200, { message: 'cleared' }]
    else
      [404, { message: 'cache not found' }]
    end

    render json: data, status: status
  end

  def cache
    key = if params[:key]
      params[:key]
    else
      device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
      lat, lng = params.fetch('location', '22.3245866064,114.173473119').split(',')
      lat.strip!
      lng.strip!
      today = params.fetch 'date', Time.now
      today = (today.is_a?String) ? DateTime.parse(today + " +08:00") : today
      route = params.fetch :route, 1

      cache_key(device_id, lat, lng, today, route)
    end

    status, data = if params[:key] && Rails.cache.exist?(key)
      url = Rails.cache.read("#{key}_url")
      query = Rails.cache.read("#{key}_query")
      formated_query = query.clone
      formated_query[:format_date] = Time.at(query[:local_time])
      status, data = Rails.cache.read("#{key}")
      [200, {
        api: "#{url}?#{query.to_query}",
        url: url,
        query: formated_query,
        data: status ? data[:entry] : data[:message],
        }]
    else
      [404, { message: 'cache not found' } ]
    end

    render json: data, status: status
  end

  private
    def parse_poi(lat, lng, data)
      arrival_time = Time.at(data[:arrival_time])
      now = Time.now
      data[:catename] = POI_CATEGORY[data[:cateid].to_s]
      data[:lat] = data[:geo][0]
      data[:lng] = data[:geo][1]
      data[:distance] = Haversine.distance(lat.to_f, lng.to_f, data[:lat], data[:lng]).to_kilometers.round(2)
      data[:local_time] = data[:arrival_time]
      data[:arrival_time] = arrival_time.strftime('%H:%M')
      data[:duration] = (data[:duration] / 60).round
      data[:selected] = now > arrival_time ? false : true

      data
    end

    def cache_key(device_id, lat, lng, time, route)
      time = time.strftime("%Y%m%d%H")
      hash = Digest::MD5.hexdigest([device_id, lng, lat].join('-')).upcase
      [hash, time, route].join('-')
    end

    def parse_traffic(data)
      data[:mode] = TRIPMODE.has_key?(data[:tripmode].downcase) ? TRIPMODE[data[:tripmode].downcase] : data[:tripmode]
      data[:traffic_time] = (data[:traffic_time] / 60).round

      if data[:segments].is_a?(String)
        if data[:segments] == '""'
          data[:segments] = []
        else
          data[:segments] = JSON.parse(data[:segments])
        end
      end

      data
    end

    ##
    # RA 接口：两点交通查询
    #
    def ra_traffic_between_two_pois(params)
      url = 'http://doraemon.qyer.com/poi/p2p_traffic'
      http_request('get', url, params) do |json, url, params|
        if json[:status] == 'success'
          [true, json[:data]]
        else
          [false, {
            api: "#{url}?#{params.to_query}",
            url: url,
            query: params,
            message: json[:msg]
          }]
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
      expires_hours = expires_in/60/60
      logger.debug "Daytour cache key: #{key} and expires in #{expires_hours} hours"

      cache_exist = Rails.cache.exist?(key)
      status, data = Rails.cache.fetch(key, expires_in: expires_in) do
        # 缓存请求的 url
        Rails.cache.write("#{key}_url", url)
        Rails.cache.write("#{key}_query", params)
        # 网络请求
        http_request('get', url, params) do |json, url, params|
          if json[:status] == 'success'
            [true, { cache: key, entry: json[:data] }]
          else
            [false, { cache: key, message: json[:msg] }]
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
      lat, lng = params.fetch('location', '22.3245866064,114.173473119').split(',')
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

      key = cache_key(params[:device_id], query[:lat], query[:lng], Time.at(query[:local_time]), params[:route])

      response = http_request('get', url, query) do |json, url, params|
        if json.is_a?(Hash) && json[:status] == 'success'
          [true, { cache: key, entry: json[:data] }]
        else
          [false, { cache: key, message: json[:msg] }]
        end
      end

      now = Time.at(query[:local_time]).to_datetime
      expires_date = DateTime.new(now.year, now.month, now.day, 23, 59, 59, '+08:00')
      expires_in = (expires_date.hour - now.hour).hours
      expires_hours = expires_in/60/60
      logger.debug "Daytour cache key: #{key} and expires in #{expires_hours} hours"
      if Rails.cache.exist?(key)
        Rails.cache.delete key
        logger.debug "Cache had been updated"
      end
      Rails.cache.write("#{key}_url", url)
      Rails.cache.write("#{key}_query", query)
      Rails.cache.write key, response

      response
    end


    def ra_upload_location(params)
      lat, lng = params.fetch('location', '22.3245866064,114.173473119').split(',')
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
          json = JSON.parse r, symbolize_keys: true
          logger.debug "RA response: #{json}"
          if block_given?
            status, data = yield(json, url, params)
          else
            status = true
            data = json
          end
        end
      rescue => e
        logger.fatal "RA error: #{e.message}"
        logger.fatal e.backtrace.join("\n")

        data = e
      end

      [status, data]
    end
end
