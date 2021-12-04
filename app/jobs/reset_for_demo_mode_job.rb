# frozen_string_literal: true

class ResetForDemoModeJob < ApplicationJob
  include DemomodeHelper

  queue_as :schedule

  def perform
    unless demo_mode?
      logger.warn("Zealot is not in demo mode, can not execute ResetForDemoModeJob.")
      return
    end

    clean_apps
    clean_users
    init_demo_data
    reset_jobs
  end

  private

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

  def reset_jobs
    require 'sidekiq/api'

    Sidekiq::RetrySet.new.clear
    Sidekiq::DeadSet.new.clear
    Sidekiq::FailureSet.new.clear
    Sidekiq::Stats.new.reset
  end

  def init_demo_data
    user = CreateAdminService.new.call
    CreateSampleAppsService.new.call(user)
  end
end
