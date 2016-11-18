class Apps::ChangelogsController < ApplicationController
  def edit
    @release = Release.find_by(version: params[:id])
    @app = @release.app
  end

  def update
    @release = Release.find_by(version: params[:id])
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @release

    @release.update!(changelog: params[:changelog])
    redirect_to app_path(@release.app.slug, @release.version)
  end
end
