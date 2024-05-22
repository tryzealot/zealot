# frozen_string_literal: true

module DemomodeHelper
  def default_admin?(user)
    user.email == Setting.admin_email
  end

  def default_admin_in_demo_mode?(user)
    default_admin?(user) && Setting.demo_mode
  end
end
