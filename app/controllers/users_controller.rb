class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def messages
    @messages = Message.where(user_id:params[:id])
                       .order('timestamp DESC')
                       .paginate(:page => params[:page])
  end

  def chatrooms
    query = params[:user].chomp if params[:user]
    if request.request_method == 'GET' && query
      @member = Qyer::Member.where('uid=? OR username=?', query, query).take
      return unless @member
      @user = Member.find_by(user_id:@member.uid)

      url = "http://api.im.qyer.com/v1/im/topic_info.json"
      query = {
        :key => '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx'
      }

      if @user
        @chatrooms = []
        Chatroom.all.each do |c|
          begin
            query[:id] = c.im_topic_id
            r = RestClient.get url, {:params => query}
            ds = MultiJson.load r

            if r.code == 200 && ds['meta']['code'] == 200
              if ds['response']['topic']['parties'].include?@user.im_user_id
                @chatrooms.push c
              end
            end
          rescue Exception => e
            next
          end
        end
      end
    end
  end

  # 注销用户的聊天室
  def kickoff
    @user = Member.find_by(user_id:params[:id])
    url = 'http://api.im.qyer.com/v1/im/remove_clients.json'
    query = {
      :key => '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
      :client => @user.im_user_id,
    }

    params[:topics].split(',').each do |id|
      begin
        query[:id] = id
        r = RestClient.post url, query
        ds = MultiJson.load r

        if r.code == 200 && ds['meta']['code'] == 200
          logger.debug "User #{@user.im_user_id} logged out topic: #{id}"
        end
      rescue Exception => e
        next
      end
    end

    redirect_to :back, :flash => {:notice => '该用户已退出所有聊天室'}
  end
end
