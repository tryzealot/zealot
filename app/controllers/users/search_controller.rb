class Users::SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = '寻找穷游用户'
    query = params[:user].chomp if params[:user]

    if request.request_method == 'GET' && query
      @member = Qyer::Member.select(:uid, :username).where('uid=? OR username=?', query, query).take
      return unless @member
      @user = Member.find_by(user_id: @member.uid)

      if @user && ! @user.im_user_id.blank?
        logger.debug "Search user: #{@user.im_user_id}"
        @user_online = user_status(@user)
      end
    end
  end

  private

  def user_status(user)
    url = 'http://api.im.qyer.com/v1/im/client_status.json'
    query = {
      key: Mobile.im_api_key,
      client: user.im_user_id
    }

    r = RestClient.get url, params: query
    ds = JSON.parse(r)

    if r.code == 200 && ds['meta']['code'] == 200
      ds['response']['status'][0][user.im_user_id]
    else
      false
    end
  end
end
