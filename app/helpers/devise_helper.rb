# frozen_string_literal: true

module DeviseHelper
  def ldap_auth_enable?
    devise_mapping.omniauthable? && resource_class.oauth_providers.include?(:ldap)
  end
end