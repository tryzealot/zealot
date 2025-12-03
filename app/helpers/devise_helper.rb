# frozen_string_literal: true

module DeviseHelper
  def devise_provider_login_path(name)
    fallback_title = omniauth_display_name(name)
    key = fallback_title.downcase

    provider = t("devise.shared.links.provider.#{key}", default: fallback_title)
    title = t('devise.shared.links.sign_in_with_provider', provider: provider)
    url = [:user, name.to_sym, :omniauth, :authorize]
    icon = (key == 'openidconnect') ? 'openid' : key

    button_to(url, class: 'btn w-full flex flex-row', method: :post, data: { turbo: false }) do
      concat(content_tag(:span, title, class: 'grow text-left'))
      concat(content_tag(:i, nil, class: "fa-brands fa-#{icon}"))
    end
  end

  def ldap_auth_enable?
    devise_mapping.omniauthable? && resource_class.oauth_providers.include?(:ldap)
  end
end
