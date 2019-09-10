class DashboardsController < ApplicationController
  before_action :authenticate_user!

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
      dsyms: Dsym.count
    }
  end
end
