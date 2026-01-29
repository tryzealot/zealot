# frozen_string_literal: true

module DeviseHelper
  def devise_provider_login_path(name)
    fallback_title = omniauth_display_name(name)
    key = fallback_title.downcase

    provider = t("devise.shared.links.provider.#{key}", default: fallback_title)
    title = t('devise.shared.links.sign_in_with_provider', provider: provider)
    url = [:user, name.to_sym, :omniauth, :authorize]
    icon = (key == 'openidconnect') ? 'openid' : key

    icon_element = case key
                   when 'gitea' 
                     vite_image_tag("images/icons/#{icon}.svg", class: 'w-4 h-4 mr-0.5')
                   when 'feishu'
                     vite_image_tag("images/icons/#{icon}.png", class: 'w-4 h-4')
                   else 
                     content_tag(:i, nil, class: "fa-brands fa-#{icon}")
                   end

    button_to(url, class: 'd-btn w-full flex flex-row', method: :post, data: { turbo: false }) do
      concat(content_tag(:span, title, class: 'grow text-left'))
      concat(icon_element)
    end
  end

  def ldap_auth_enable?
    devise_mapping.omniauthable? && resource_class.oauth_providers.include?(:ldap)
  end
end
