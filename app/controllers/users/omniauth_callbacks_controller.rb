# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      flash[:success] = 'Google Account 授权并登录成功'
      sign_in_and_redirect @user #, event: :authentication # this will throw if @user is not activated
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    flash[:error] = '授权失败，请检查你的信息是否正确'
    redirect_to root_path
  end
end
