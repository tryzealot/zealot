# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy lock unlock]

  def index
    @users = User.all.order(id: :asc)
    authorize @users
  end

  def new
    @title = t('admin.users.new_user')
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new_with_session(user_params, session)
    authorize @user

    return render :new, status: :unprocessable_entity unless @user.save

    redirect_to admin_users_path, notice: t('activerecord.success.create', key: t('admin.users.title'))
  end

  def edit
    authorize @user

    @title = @user.email
  end

  def update
    authorize @user

    if helpers.default_admin_in_demo_mode?(@user)
      return redirect_to admin_users_path, alert: t('errors.messages.invaild_in_demo_mode')
    end

    # 没有设置密码的情况下不更新该字段
    params = user_params.dup
    params.delete(:password) if params[:password].blank?
    return render :edit, status: :unprocessable_entity unless @user.update(params)

    redirect_to admin_users_path, notice: t('activerecord.success.update', key: t('admin.users.title'))
  end

  def destroy
    if helpers.default_admin_in_demo_mode?(@user)
      return redirect_to admin_users_path, alert: t('errors.messages.invaild_in_demo_mode')
    end

    authorize @user

    @user.destroy

    notice = t('activerecord.success.destroy', key: t('admin.users.title'))
    redirect_to admin_users_path, status: :see_other, notice: notice
  end

  def lock
    @user.lock_access!(send_instructions: false)
    redirect_to edit_admin_user_path(@user), notice: t('.message', user: @user.username)
  end

  def unlock
    @user.unlock_access!
    redirect_to edit_admin_user_path(@user), notice: t('.message', user: @user.username)
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :role, :locale, :appearance, :timezone)
  end
end
