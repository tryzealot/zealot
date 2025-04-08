# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  User.oauth_providers.each do |provider_name|
    define_method(provider_name) do
      omniauth_callback(provider_name)
    end
  end

  def passthru
    # User had been logged in, redirect to root page
    redirect_to root_path(signin: 'true')
  end

  private

  def omniauth_callback(name)
    auth = request.env['omniauth.auth']
    strategy = request.env['omniauth.strategy']
    required_org = strategy.options[:required_org]
    provider = UserProvider.find_by(name: auth.provider, uid: auth.uid)

    if auth.provider == 'github' && required_org.present?
      begin
        check_github_org(auth, required_org)
      rescue => e
        flash[:alert] = e.message
        redirect_to new_user_session_path
        return
      end
    end
    
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

  def check_github_org(auth, required_org)
    token = auth.credentials.token

    uri = URI("https://api.github.com/user/orgs")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["User-Agent"] = "zealot"
  
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    raise t("devise.github.org_check_fail", code: res.code) unless res.is_a?(Net::HTTPSuccess)
    orgs = JSON.parse(res.body).map { |org| org["login"] }
    raise t("devise.github.org_required_fail", required_org: required_org) unless orgs.include?(required_org)
  end

  def connect_user_to_provider(name, auth)
    current_user.providers.from_omniauth(auth)

    bypass_sign_in(current_user)
    redirect_to goback_path, notice: t('devise.omniauth_callbacks.success', kind: name)
  end

  def store_new_user(name, auth)
    begin
      user = User.from_omniauth(auth)
      flash[:notice] = t('devise.registrations.signed_up')
      sign_in_and_redirect user
    rescue => e
      flash[:alert] = e.message
      redirect_to new_user_session_path
    end
  end

  def goback_path
    omni_params = request.env['omniauth.params']
    omni_params&['back'].presence || request.env['HTTP_REFERER'] || root_path
  end
end
