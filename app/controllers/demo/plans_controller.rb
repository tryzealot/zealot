class Demo::PlansController < ApplicationController
  # before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  ##
  # 个性化行程推荐列表
  #
  def index
    @title = "智能行程推荐演示"

    @uid = params.fetch 'uid', 1357827
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @lon, @lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
    @lat.strip!
    @lon.strip!
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + " +08:00") : @today
    @route = params.fetch :route, 1
  end

  ##
  # 每日上报用户地理坐标
  #
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

  ##
  # 保存用户上报坐标
  # 需要处理：
  # 1. 保存记录到缓存
  # 2. 回调 RA 接口
  #
  def store_record
    cache_key = "#{params[:device_id]}-#{params[:date]}"
    @locations = Rails.cache.fetch(cache_key) do
      []
    end

    @locations.append(params)
    Rails.cache.write(cache_key, @locations)

    status, data = upload_location(params)
    render json: data
  end

  ##
  # 根据地址查询坐标
  # 使用百度地图接口
  #
  def address2geo(address)
    url = 'http://api.map.baidu.com/geocoder/v2/'
    params = {
      address: address,
      output: 'json',
      ak: '4E23365d590adb14920d402a12929e2d'
    }

    http_request('get', url, params) do |json|
      if json[:status] == 0
        data = json[:result]
        status = true
      else
        data =  { error: json[:msg] }
      end
    end
  end

  private
    ##
    # RA 接口：上报坐标
    # 无需管返回数据
    #
    def upload_location(params)
      lon, lat = params.fetch('location', '114.173473119,22.3245866064').split(',')
      lon.strip!
      lat.strip!

      query = {
        device_id: params[:device_id],
        local_time: DateTime.parse("#{params[:date]} #{params[:time]} +08:00").to_i,
        lat: lat,
        lng: lon,
        uid: 1357827,
      }

      url = 'http://doraemon.qyer.com/recommend/onroad/update_loc/'
      http_request('get', url, query)
    end

    ##
    # RA 接口：用户可能去过景点列表
    #
    def maybes(params)
      url = "http://doraemon.qyer.com/recommend/onroad/might_beento_pois/"
      status, data = http_request('get', url, params) do |json|
        if json[:status] == 'success'
          [true, json[:data]]
        else
          [false, { error: json[:msg] }]
        end
      end
    end
end
