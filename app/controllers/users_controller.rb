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
    else

    end
  end

end
