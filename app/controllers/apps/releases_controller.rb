class Apps::ReleasesController < AppsController
  before_action :set_app

  def index
    @title = "#{@app.name} - 主版本列表"
  end

  def show
    @app_releases = @app.releases.where(release_version: params[:version])
  end
end
