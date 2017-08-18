class VisitorsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @title = '我的控制台'

    system_analytics
    recently_upload
  end

  private

  def recently_upload
    @releases = Release.order(id: :desc).page(params.fetch(:page, 1)).per(params.fetch(:per_page, 10))
  end

  def system_analytics
    @analytics = {
      apps: App.count,
      releases: Release.count,
      dsyms: Dsym.count,
      pacs: Pac.count
    }
  end
end
