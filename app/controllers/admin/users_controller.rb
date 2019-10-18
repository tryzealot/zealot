class Admin::UsersController < ApplicationController
  before_action :admin_user?
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @title = '用户管理'
    @users = User.all
  end

  def show
    @roles = Role.all
    redirect_back fallback_location: root_path , notice: '你没有权限管理。' unless @user.roles?(:admin)
  end

  def new
    @title = '新建用户'
    @user = User.new
  end

  def create
    @user = User.new(user_params) do |u|
      # 新建用户需要激活才能设置密码，这里生成一个随机密码
      u.password = Time.now.utc
    end

    return render :new unless @user.save

    # 更新权限
    @user.update_roles(params[:user][:role_ids])

    # 发送激活邮件
    UserMailer.activation_email(@user).deliver_later

    redirect_to admin_users_url, notice: "用户创建成功，打开 #{@user.email} 邮箱查收激活邮件"
  end

  def edit
    @title = '编辑用户'
  end

  def update
    @title = '编辑用户'

    # 没有设置密码的情况下不更新该字段
    # user_params[:password] = @user.password if user_params[:password].blank?

    if @user.update(user_params)
      @user.update_roles(params[:user][:role_ids])
      redirect_to admin_users_url, notice: '用户已经更新'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, notice: '用户已经删除'
  end

  private

  def admin_user?
    authenticate_user!
    # unless current_user.roles?(:admin)
    #   redirect_back fallback_location: root_path, notice: '你没有权限管理。'
    # end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :username, :email, :password
    )
  end
end
