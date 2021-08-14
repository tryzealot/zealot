# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    omniauth_callback('Google ', 'google_data')
  end

  def ldap
    omniauth_callback('LDAP ', 'ldap_data')
  end

  def feishu
    omniauth_callback('飞书', 'feishu_data')
  end

  def gitlab
    omniauth_callback('Gitlab', 'gitlab_data')
  end

  def failure
    flash[:error] = "授权失败！请检查你的账户和密码是否正确，原始错误信息：#{failure_message}"
    redirect_to goback_path
  end

  private

  def omniauth_callback(name, session_key)
    auth = request.env['omniauth.auth']
    provider = UserProvider.find_by(name: auth.provider, uid: auth.uid)

    # Existed provider?
    if provider
      provider.update_omniauth(auth.credentials)

      flash[:notice] = "#{name}账户已登录"
      return sign_in_and_redirect provider.user
    end

    if user_signed_in?
      connect_user_to_provider(name, auth)
    else
      store_new_user(name, auth)
    end
  end

  private

  def connect_user_to_provider(name, auth)
    current_user.providers.from_omniauth(auth)

    bypass_sign_in(current_user)
    redirect_to goback_path, notice: "#{name}账户已关联"
  end

  def store_new_user(name, auth)
    user = User.from_omniauth(auth)
    flash[:notice] = "#{name}账户已授权并创建用户"
    sign_in_and_redirect user
  end

  def goback_path
    omni_params = request.env['omniauth.params']
    redirect_path = omni_params['back'].presence || root_path
  end
end
