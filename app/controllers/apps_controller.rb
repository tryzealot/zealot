class AppsController < ApplicationController

  before_filter :check_user_logged_in!

  def index
    if user_signed_in?
      @apps = current_user.apps
    else
      redirect_to new_user_session_path
    end
  end

  def show
    @app = App.find_by(slug: params[:slug])
    if ! @app
      raise ActionController::RoutingError.new('这里没有你找的东西')
    end

    @release = @app.releases.last
  end

  def release
    @release = Release.find(params[:id])
    @app = @release.app

    render 'apps/show'
  end

  def edit
    @app = App.find_by(slug: params[:slug])
    if ! @app
      raise ActionController::RoutingError.new('这里没有你找的东西')
    end
  end

  def update
    @app = App.find(params[:id])
    if ! @app
      raise ActionController::RoutingError.new('这里没有你找的东西')
    end

    @app.update({
      name: params[:name],
      slug: params[:slug]
      })
    redirect_to apps_path
  end

  def destroy
    App.find_by(slug: params[:slug]).destroy
    redirect_to apps_path
  end

  private
    def check_user_logged_in!
      unless request.user_agent.include?"MicroMessenger"
        authenticate_user!
      end
    end

end
