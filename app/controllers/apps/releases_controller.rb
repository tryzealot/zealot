class Apps::ReleasesController < AppsController
  before_action :set_app

  def index
    @title = "#{@app.name} #{@app.device_type} 主版本列表"
  end

  def show
    @title = "#{@app.name} #{@app.device_type} #{params[:version]} 版本列表"
    @app_releases = @app.releases.where(release_version: params[:version])
  end
end
