# frozen_string_literal: true

module DeviseHelper
  def devise_provider_login_path(name)
    fallback_title = omniauth_display_name(name)
    key = fallback_title.downcase

    provider = t("devise.shared.links.provider.#{key}", default: fallback_title)
    title = t('devise.shared.links.sign_in_with_provider', provider: provider)
    url = [:user, name.to_sym, :omniauth, :authorize]
    button_to(url, class: "btn btn-block btn-default text-left") do
      raw(%Q(#{title} <i class="icon fab float-right fa-#{key}"></i>))
    end
  end

  def ldap_auth_enable?
    devise_mapping.omniauthable? && resource_class.oauth_providers.include?(:ldap)
  end
end