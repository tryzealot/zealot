class Apps::ReleasesController < ApplicationController
  before_action :set_app

  def index
    @title = "#{@app.name} - 主版本列表"
  end

  def show
    @app_releases = @app.releases.where(release_version: params[:version])
  end

  def edit
  end

  private

  def set_app
    @app =
      if params[:slug]
        App.friendly.find(params[:slug])
      else
        App.find(params[:id])
      end
  end
end
