# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    omniauth_callback('Google', 'google_data')
  end

  def ldap
    omniauth_callback('LDAP', 'ldap_data')
  end

  # def failure
  #   flash[:error] = failure_message
  #   flash[:error] = '授权失败！请检查你的账户和密码是否正确，如果输入确认无误还是失败请联系管理员检查配置是否正确'
  #   redirect_to root_path
  # end

  private

  def omniauth_callback(provider, session_key)
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      flash[:notice] = "#{provider} 账户授权并登录成功"
      sign_in_and_redirect @user
    else
      session["devise.#{session_key}"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
