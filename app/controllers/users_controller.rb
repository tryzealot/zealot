class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @title = '用户管理'
    @users = User.all
  end

  def show
    @roles = Role.all
    redirect_to :back, alert: 'Access denied.' unless @user == current_user || @user.roles?(:admin)
  end

  def new
    @title = '新建用户'
    @user = User.new
  end

  def create
    @title = '新建用户'
    @user = User.new(user_params)
    if @user.save
      redirect_to users_url, notice: '用户创建成功'
    else
      render :new
    end
  end

  def edit
    @title = '编辑用户'
  end

  def update
    @title = '编辑用户'

    # 没有设置密码的情况下不更新该字段
    user_params[:password] = @user.password if user_params[:password].blank?

    if @user.update(user_params)
      redirect_to users_url, notice: '用户已经更新'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: '用户已经删除'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name, :email, :password, :roles
    )
  end
end
