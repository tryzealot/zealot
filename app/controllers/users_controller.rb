class UsersController < ApplicationController
  before_filter :authenticate_user!

  JK_KEY = '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx'.freeze

  def index
    @users = []
  end

  def show
    @user = User.find(params[:id])
    redirect_to :back, alert: 'Access denied.' unless @user == current_user
  end

  def groups
    @title = '查找用户'
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
      key: JK_KEY,
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
