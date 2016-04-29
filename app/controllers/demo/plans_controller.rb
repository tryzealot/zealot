class Demo::PlansController < ApplicationController
  # before_filter :authenticate_user!

  ##
  # 个性化行程推荐列表
  #
  def index
    @title = '智能行程推荐演示'
    @uid = params.fetch 'uid', 1_357_827
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @location = params.fetch('location', '22.3245866064,114.173473119')
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + ' +08:00') : @today
    @route = params.fetch :route, 1
  end

  ##
  # 每日上报用户地理坐标
  #
  def record
    @device_id = params.fetch 'device_id', '21EBA128-C884-4B22-8327-F9BD8A089FD7'
    @today = params.fetch 'date', Time.now
    @today = (@today.is_a?String) ? DateTime.parse(@today + ' +08:00') : @today

    cache_key = "#{@device_id}-#{@today.strftime('%Y-%m-%d')}"
    # Rails.cache.delete cache_key
    @locations = Rails.cache.fetch(cache_key) do
      []
    end
  end

  ##
  # 根据地址查询坐标
  # 使用百度地图接口
  #
  # def address2geo(address)
  #   url = 'http://api.map.baidu.com/geocoder/v2/'
  #   params = {
  #     address: address,
  #     output: 'json',
  #     ak: '4E23365d590adb14920d402a12929e2d'
  #   }
  #
  #   http_request('get', url, params) do |json|
  #     if json[:status] == 0
  #       data = json[:result]
  #       status = true
  #     else
  #       data =  { error: json[:msg] }
  #     end
  #   end
  # end

  private

  ##
  # RA 接口：用户可能去过景点列表
  #
  def maybes(params)
    url = 'http://doraemon.qyer.com/recommend/onroad/might_beento_pois/'
    http_request('get', url, params) do |json|
      if json[:status] == 'success'
        [true, json[:data]]
      else
        [false, { error: json[:msg] }]
      end
    end
  end
end
