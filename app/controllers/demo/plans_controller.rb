class Demo::PlansController < ApplicationController

  def index
    debug_mode = params.fetch 'debug', false
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @lat, @lon = params.fetch('location', '22.3245866064,114.173473119').split(',')
    @lat.strip!
    @lon.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today) : @today

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

  private
    def daytours(query)
      url = 'http://doraemon.qyer.com/recommend/onroad/daytours'
      status = true
      data = []
      r = RestClient.get url, { params: query }
      if r.code == 200
        json = MultiJson.load r, symbolize_keys: true
        if json[:status] == 'success'
          data = json[:data]
        else
          status = false
          data = json[:data]
        end
      end

      [status, data]
    end
end
