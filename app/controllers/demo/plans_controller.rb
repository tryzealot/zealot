class Demo::PlansController < ApplicationController
  # before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  def index
    @title = "智能行程推荐演示"

    debug_mode = params.fetch 'debug', false
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @lon, @lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
    @lat.strip!
    @lon.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + " +08:00") : @today

    if request.request_method == 'POST'
      query = {
        lat: @lat,
        lng: @lon,
        local_time: @today.to_i,
        device_id: @device_id,
        route: 1
      }

      tours_status, tours_data = if debug_mode
        Rails.cache.fetch("#{today.to_i.to_s}_daytours", expires_in: 1.hour) do
          daytours(query)
        end
      else
        daytours(query)
      end

      maybe_status, @maybe_pois = if debug_mode
        Rails.cache.fetch("#{today.to_i.to_s}_maybe_pois", expires_in: 1.hour) do
          maybes({
            device_id: @device_id,
            local_time: @today.to_i
          })
        end
      else
        maybes({
            device_id: @device_id,
            local_time: @today.to_i
          })
      end

      if tours_status
        @tours = tours_data
      else
        @error = tours_data
      end
    end
  end

  def record
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + " +08:00") : @today

    cache_key = "#{@device_id}-#{@today.strftime("%Y-%m-%d")}"
    # Rails.cache.delete cache_key
    @locations = Rails.cache.fetch(cache_key) do
      []
    end

    ap @locations
  end

  def store_record
    cache_key = "#{params[:device_id]}-#{params[:date]}"
    @locations = Rails.cache.fetch(cache_key) do
      []
    end

    @locations.append(params)
    Rails.cache.write(cache_key, @locations)

    render json: @locations
  end

  def location(address)
    url = 'http://api.map.baidu.com/geocoder/v2/'
    params = {
      address: address,
      output: 'json',
      ak: '4E23365d590adb14920d402a12929e2d'
    }

    status = false
    data = []

    logger.debug "Request url: #{url}?#{params.to_query}"
    r = RestClient.get url, { params: params }
    if r.code == 200
      json = MultiJson.load r, symbolize_keys: true
      if json[:status] == 0
        data = json[:result]
        status = true
      else
        data = json[:msg]
      end
    end

    [status, data]
  end

  private
    def upload_location(params)
      url = 'http://doraemon.qyer.com/recommend/onroad/update_loc/?device_id=xxx&uid=10&local_time=1439913540&lat=22.3245866064&lng=114.173473119'


    end



    def maybes(params)
      url = "http://doraemon.qyer.com/recommend/onroad/might_beento_pois/"
      status = false
      data = []

      logger.debug "Request url: #{url}?#{params.to_query}"
      r = RestClient.get url, { params: params }
      if r.code == 200
        json = MultiJson.load r, symbolize_keys: true
        logger.debug "response data: #{json}"
        if json[:status] == 'success'
          status = true
          data = json[:data]
        else
          data = json[:data]
        end
      end

      [status, data]
    end

    def daytours(params)
      url = 'http://doraemon.qyer.com/recommend/onroad/daytours'
      http_request('get', url, params) do |json|
        if json[:status] == 'success'
          [true, json[:data]]
        else
          [false, json[:data]]
        end
      end
    end

    def http_request(method, url, params)
      status = false
      data = []

      logger.debug "Request url: #{url}?#{params.to_query}"
      r = if method == 'get'
        RestClient.get url, { params: params }
      else
        RestClient.post url, params
      end
      if r.code == 200
        json = MultiJson.load r, symbolize_keys: true
        logger.debug "response data: #{json}"
        if block_given?
          status, data = yield(json)
        else
          status = true
          data = json
        end
      end

      [status, data]
    end
end
