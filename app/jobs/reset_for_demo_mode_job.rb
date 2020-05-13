# frozen_string_literal: true

class ResetForDemoModeJob < ApplicationJob
  queue_as :schedule

  def perform
    return unless demo_mode?

    clean_apps
    clean_users
    init_demo_data
  end

  private

  def demo_mode?
    if (value = ENV['ZEALOT_DEMO_MODE']) && value.present?
      return true if value.to_i == 1
      return true if value.downcase == 'true'
    end

    logger.warn("Zealot is not in demo mode, can not execute ResetForDemoModeJob.")

    false
  end

  def clean_apps
    apps = App.all
    apps.each do |app|
      app.destroy
    end
  end

  def clean_users
    users = User.all
    users.each do |user|
      user.destroy
    end
  end

  def init_demo_data
    user = CreateAdminService.new.call
    CreateSampleAppsService.new.call(user)
  end
end
