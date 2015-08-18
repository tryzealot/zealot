class Demo::PlansController < ApplicationController
  # before_filter :authenticate_user!

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
        route: '1,2,3'
      }

      status, data = if debug_mode
        Rails.cache.fetch("#{today.to_i.to_s}_daytours", expires_in: 1.hour) do
          daytours(query)
        end
      else
        daytours(query)
      end

      if status
        @tours = data
      else
        @error = data
      end
    end
  end

  def oneday
  end

  def create
  end

  def destroy
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
    def daytours(params)
      url = 'http://doraemon.qyer.com/recommend/onroad/daytours'
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
end
