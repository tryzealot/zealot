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

  def messages
    @title = '用户聊天历史'
    @messages = Message.where(user_id: params[:id])
                       .order('timestamp DESC')
                       .page(params[:page])

    render 'groups/messages'
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

  # 注销用户的聊天室
  def kickoff
    @user = Member.find_by(user_id: params[:id])
    url = 'http://api.im.qyer.com/v1/im/remove_clients.json'
    query = {
      key: JK_KEY,
      client: @user.im_user_id
    }

    params[:topics].split(',').each do |id|
      begin
        query[:id] = id
        r = RestClient.post url, query
        ds = JSON.parse(r)

        if r.code == 200 && ds['meta']['code'] == 200
          logger.debug "User #{@user.im_user_id} logged out topic: #{id}"
        end
      rescue
        next
      end
    end

    redirect_to :back, flash: { notice: '该用户已退出所有聊天室' }
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
