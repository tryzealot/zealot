class Api::V1::UserController < Api::V1::ApplicationController
  def show
    query = params[:id]
    @member = Qyer::Member.select(:uid, :username).where('uid=? OR username=?', query, query).take

    status, data =
      if @member
        @user = Member.find_by(user_id: @member.uid)

        [200, {
          id: @member.uid,
          im_user_id: @user ? @user.im_user_id : nil,
          username: @member.username,
          device_id: @user ? @user.deviceid : nil
          }]
      else
        [404, { message: 'user not found' }]
      end

    render json: data, status: status
  end
end
