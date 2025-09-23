# frozen_string_literal: true

module UserOmniauth
  extend ActiveSupport::Concern

  def from_omniauth(auth)
    # email = auth.info.email
    password = Devise.friendly_token[0, 20]
    user = User.find_or_initialize_by(email: auth.info.email) do |u|
      u.username = auth.info.name
      u.password = password
    end
    new_record = user.new_record?

    user.skip_confirmation!
    user.remember_me!
    user.save!(validate: false)

    user.providers.from_omniauth(auth)

    return user unless new_record

    UserMailer.omniauth_welcome_email(user, password).deliver_later

    user
  end

  def oauth_providers
    @oauth_providers ||= Devise.omniauth_providers.each_with_object([]) do |name, obj|
      obj << name if enabled?(name)
    end
  end

  def enabled?(name)
    send("enabled_#{name}?".to_sym)
  end

  def enabled_google_oauth2?
    defined?(OmniAuth::Strategies::GoogleOauth2) && Setting.google_oauth[:enabled]
  end

  def enabled_ldap?
    defined?(OmniAuth::Strategies::LDAP) && Setting.ldap[:enabled]
  end

  def enabled_openid_connect?
    defined?(OmniAuth::Strategies::OpenIDConnect) && Setting.oidc[:enabled]
  end

  def enabled_feishu?
    defined?(OmniAuth::Strategies::Feishu) && Setting.feishu[:enabled]
  end

  def enabled_gitlab?
    defined?(OmniAuth::Strategies::GitLab) && Setting.gitlab[:enabled]
  end

  def enabled_github?
    defined?(OmniAuth::Strategies::GitHub) && Setting.github[:enabled]
  end

  def enabled_gitea?
    defined?(OmniAuth::Strategies::Gitea) && Setting.gitea[:enabled]
  end
end
