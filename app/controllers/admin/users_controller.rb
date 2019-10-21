# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @title = '用户管理'
    @users = User.all
  end

  def show
    redirect_back fallback_location: root_path
  end

  def new
    @title = '新建用户'
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    return render :new unless @user.save

    redirect_to admin_users_url, notice: '用户创建成功'
  end

  def edit
    @title = '编辑用户'
  end

  def update
    # 没有设置密码的情况下不更新该字段
    user_params.delete(:password) if user_params[:password].blank?
    return render :edit unless @user.update(user_params)

    redirect_to admin_users_url, notice: '用户已经更新'
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, notice: '用户已经删除'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :role)
  end
end
