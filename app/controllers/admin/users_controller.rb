# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  def index
    @title = t('users.title')
    @users = User.all
    authorize @users
  end

  def new
    @title = t('admin.users.new_user')
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    return render :new unless @user.save

    redirect_to admin_users_url, notice: t('activerecord.success.create', key: t('users.title'))
  end

  def edit
    @title = @user.email
  end

  def update
    if helpers.default_admin_in_demo_mode?(@user)
      return redirect_to admin_users_url, alert: t('errors.invaild_in_demo_mode')
    end

    # 没有设置密码的情况下不更新该字段
    params = user_params.dup
    params.delete(:password) if params[:password].blank?
    return render :edit unless @user.update(params)

    redirect_to admin_users_url, notice: t('activerecord.success.update', key: t('users.title'))
  end

  def destroy
    if helpers.default_admin_in_demo_mode?(@user)
      return redirect_to admin_users_url, alert: t('errors.invaild_in_demo_mode')
    end

    @user.destroy
    redirect_to admin_users_url, notice: t('activerecord.success.destroy', key: t('users.title'))
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :role)
  end
end
