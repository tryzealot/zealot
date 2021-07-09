# frozen_string_literal: true

module DemomodeHelper
  def demo_mode?
    if (value = ENV['ZEALOT_DEMO_MODE']) && value.present?
      return true if value.to_i == 1
      return true if value.downcase == 'true'
    end

    false
  end

  def default_admin?(user)
    user.email == Setting.admin_email
  end

  def default_admin_in_demo_mode?(user)
    default_admin?(user) && demo_mode?
  end
end