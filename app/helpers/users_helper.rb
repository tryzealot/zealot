# frozen_string_literal: true

module UsersHelper
  def guest_mode_or_signed_in?
    Setting.guest_mode? || user_signed_in?
  end

  def user_roles
    User.roles.to_a.collect { |c| [Setting.builtin_roles[c[0].to_sym], c[0]] }
  end

  def collaborator_roles
    Collaborator.roles.to_a.collect { |c| [Setting.builtin_roles[c[0].to_sym], c[0]] }
  end

  def omniauth_display_name(provider)
    case provider
    when :ldap
      provider.to_s.upcase
    else
      OmniAuth::Utils.camelize(provider).sub('Oauth2', '')
    end
  end
end
