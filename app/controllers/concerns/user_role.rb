# frozen_string_literal: true

module UserRole
  extend ActiveSupport::Concern

  def user_signed_in_or_guest_mode?
    Setting.guest_mode || user_signed_in?
  end

  def manage_user_or_guest_mode?(app: nil)
    Setting.guest_mode || manage_user?(app: app)
  end

  def manage_user?(app: nil)
    current_user&.manage? || (app && current_user&.manage?(app: app))
  end
end
