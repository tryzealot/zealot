class Api::V1::UserController < Api::ApplicationController
  def show
    query = params[:id]
    @member = Qyer::Member.select(:uid, :username).where('uid=? OR username=?', query, query).take

    status, data = if @member
      @user = Member.find_by(user_id: @member.uid)

      ap @user
      [200, {
        id: @member.uid,
        im_user_id: @user.im_user_id,
        username: @member.username,
        device_id: @user.deviceid
        }]
    else
      [404, { message: 'user not found' }]
    end

    render json: data, status: status
  end
end
