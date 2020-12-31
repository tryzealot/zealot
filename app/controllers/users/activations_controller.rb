# frozen_string_literal: true

class Users::ActivationsController < ApplicationController
  before_action :verify_user
  rescue_from ActiveRecord::RecordNotFound, with: :render_unprocessable_entity_response

  def edit
  end

  def update
    if @user.active(user_params)
      redirect_to new_user_session_url, notice: '账户已激活，请使用邮箱和刚设置的密码登录。'
    else
      render :edit
    end
  end

  private

  def verify_user
    return redirect_back fallback_location: root_path, notice: '你已经登录，无法激活其他账户。' if current_user

    @title = '激活你的账户'
    @user = User.find_by!(activation_token: params[:token])
  end

  def render_unprocessable_entity_response(_)
    flash[:alert] = '无效的激活码'
    render 'empty'
  end

  def user_params
    params.require(:user).permit(:password)
  end
end
