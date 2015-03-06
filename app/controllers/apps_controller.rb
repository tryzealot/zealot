class AppsController < ApplicationController

  def index
    if user_signed_in?
      @apps = current_user.apps
    else
      redirect_to new_user_session_path
    end
  end

  def show
    @app = App.find_by(slug: params[:slug])
    @release = @app.releases.last

    if ! @app
      raise ActionController::RoutingError.new('这里没有你找的东西')
    end
  end

  def release
    @release = Release.find(params[:id])
    @app = @release.app

    render 'apps/show'
  end

  # def edit
  #   @app = App.find(params[:id])
  # end

end
