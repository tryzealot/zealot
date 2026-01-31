# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy lock unlock resend_confirmation]

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

    flash.now[:notice] = t('activerecord.success.create', key: t('admin.users.title'))
    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.turbo_stream
    end
  end

  def edit
    authorize @user

    @title = @user.email
    @user.send(:generate_confirmation_token!) if @user.send(:confirmation_period_expired?)
  end

  def update
    authorize @user

    if helpers.default_admin_in_demo_mode?(@user)
      return redirect_to admin_users_path, alert: t('errors.messages.invaild_in_demo_mode')
    end

    # Skip password if not set
    params = user_params.dup
    params.delete(:password) if params[:password].blank?
    return render :edit, status: :unprocessable_entity unless @user.update(params)

    flash.now[:notice] = t('activerecord.success.update', key: t('admin.users.title'))
    respond_to do |format|
      format.html { redirect_to edit_admin_user_path(@user) }
      format.turbo_stream
    end
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
    if @user.email == Setting.admin_email
      alert = t('errors.messages.cannot_lock_default_admin')
      flash.now[:alert] = alert
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
      return
    end

    @user.lock_access!(send_instructions: false)
    flash.now[:notice] = t('.message', user: @user.username)
    respond_to do |format|
      format.html { redirect_to edit_admin_user_path(@user) }
      format.turbo_stream
    end
  end

  def unlock
    @user.unlock_access!
    flash.now[:notice] = t('.message', user: @user.username)
    respond_to do |format|
      format.html { redirect_to edit_admin_user_path(@user) }
      format.turbo_stream
    end
  end

  def resend_confirmation
    @user.send_confirmation_instructions
    flash.now[:notice] = t('.message', user: @user.username)
    # respond_to do |format|
    #   format.html { redirect_to admin_user_path(@user) }
    #   format.turbo_stream
    # end
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
