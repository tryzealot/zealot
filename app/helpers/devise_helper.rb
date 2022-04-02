# frozen_string_literal: true

module DeviseHelper
  def devise_provider_login_path(provider)
    title = omniauth_display_name(provider)
    key = title.downcase

    url = [:user, provider.to_sym, :omniauth, :authorize]
    button_to(url, class: "btn btn-block btn-default text-left") do
      raw(%Q(
        #{t('devise.shared.links.sign_in_with_provider', provider: t("devise.shared.links.provider.#{key}", default: title))}
        <i class="icon fab float-right fa-#{key}"></i>
      ))
    end
  end

  def ldap_auth_enable?
    devise_mapping.omniauthable? && resource_class.oauth_providers.include?(:ldap)
  end
end