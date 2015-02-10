class AppController < ApplicationController
  def show
    @app = App.find_by(slug: params[:slug])
  end
end
