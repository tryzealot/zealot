class AppsController < ApplicationController
  before_filter :authenticate_user!

  def index
    if user_signed_in?
      @apps = current_user.apps
    else
      redirect_to new_user_session_path
    end

  end


  def show
    @app = App.find_by(slug: params[:slug])
  end
end
