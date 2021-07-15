# frozen_string_literal: true

module UserOmniauth
  extend ActiveSupport::Concern

  def from_omniauth(auth)
    email = auth.info.email
    username = auth.info.name
    password = Devise.friendly_token[0, 20]
    user = User.find_by(email: email)

    return user unless user.nil?

    user = User.new(email: email, username: username, password: password)
    user.skip_confirmation!
    user.remember_me!
    user.save!(validate: false)

    UserProvider.create_from_omniauth(auth, user)
    UserMailer.omniauth_welcome_email(user, password).deliver_later

    user
  end

  def oauth_providers
    omniauth_providers.each_with_object([]) do |name, obj|
      obj << name if enabled?(name)
    end
  end

  def enabled?(name)
    send("enabled_#{name}?")
  end

  def enabled_google_oauth2?
    defined?(OmniAuth::Strategies::GoogleOauth2) && Setting.google_oauth[:enabled]
  end

  def enabled_ldap?
    defined?(OmniAuth::Strategies::LDAP) && Setting.ldap[:enabled]
  end

  def enabled_feishu?
    defined?(OmniAuth::Strategies::Feishu) && Setting.feishu[:enabled]
  end

  def enabled_gitlab?
    defined?(OmniAuth::Strategies::GitLab) && Setting.gitlab[:enabled]
  end
end
