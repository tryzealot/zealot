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

  # def failure
  #   flash[:error] = failure_message
  #   flash[:error] = '授权失败！请检查你的账户和密码是否正确，如果输入确认无误还是失败请联系管理员检查配置是否正确'
  #   redirect_to root_path
  # end

  private

  def omniauth_callback(name, session_key)
    auth = request.env['omniauth.auth']
    provider = UserProvider.initialize_from_omniauth(auth)

    # Existed provider?
    if provider.persisted?
      provider.save

      flash[:notice] = "#{name}账户授权并登录成功"
      return sign_in_and_redirect provider.user
    end

    if user_signed_in?
      # Connect provider to existed user
      omni_params = request.env['omniauth.params']
      current_user.providers.create(provider)

      bypass_sign_in(current_user)
      redirect_path = omni_params['back'].presence || root_path
      redirect_to redirect_path, notice: '#{name}账户关联成功'
    else
      # New user logged in with provider
      user = User.from_omniauth(auth)
      flash[:notice] = "#{name}账户授权并登录成功"
      sign_in_and_redirect user
    end
  end

  def provider_attributes(auth)
    credentials = auth.credentials

    {
      name: auth.provider,
      uid: auth.uid,
      token: credentials.token,
      expires_at: credentials.expires_at,
      secret: credentials.secret
    }
  end
end
