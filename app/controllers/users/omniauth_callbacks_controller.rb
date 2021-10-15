# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  User.oauth_providers.each do |provider_name|
    define_method(provider_name) do
      omniauth_callback(provider_name)
    end
  end

  # def google_oauth2
  #   omniauth_callback('Google ', 'google_data')
  # end

  # def ldap
  #   omniauth_callback('LDAP ', 'ldap_data')
  # end

  # def feishu
  #   omniauth_callback('飞书', 'feishu_data')
  # end

  # def gitlab
  #   omniauth_callback('Gitlab', 'gitlab_data')
  # end

  def passthru
    redirect_to root_path(signin: 'true')
  end

  private

  def omniauth_callback(name)
    auth = request.env['omniauth.auth']
    provider = UserProvider.find_by(name: auth.provider, uid: auth.uid)

    # Existed provider?
    if provider
      provider.update_omniauth(auth.credentials)

      flash[:notice] = t('devise.omniauth_callbacks.success', kind: name)
      return sign_in_and_redirect provider.user
    end

    if user_signed_in?
      connect_user_to_provider(name, auth)
    else
      store_new_user(name, auth)
    end
  end

  def connect_user_to_provider(name, auth)
    current_user.providers.from_omniauth(auth)

    bypass_sign_in(current_user)
    redirect_to goback_path, notice: t('devise.omniauth_callbacks.success', kind: name)
  end

  def store_new_user(name, auth)
    user = User.from_omniauth(auth)
    flash[:notice] = t('devise.registrations.signed_up')
    sign_in_and_redirect user
  end

  def goback_path
    omni_params = request.env['omniauth.params']
    redirect_path = omni_params['back'].presence ||
                    request.env['HTTP_REFERER'] ||
                    root_path
  end
end
