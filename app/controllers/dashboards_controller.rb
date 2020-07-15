# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user! unless Zealot::Setting.guest_mode

  def index
    @title = '我的控制台'

    system_analytics
    recently_upload
  end

  private

  def recently_upload
    @releases = Release.page(params.fetch(:page, 1)).per(params.fetch(:per_page, 10)).order(id: :desc)
  end

  def system_analytics
    @analytics = {
      apps: App.count,
      releases: Release.count,
      debug_files: DebugFile.count,
      users: User.count
    }
  end
end
