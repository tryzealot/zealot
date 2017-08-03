class Api::V2::Apps::InstallUrlController < ApplicationController
  def show
    @app = App.friendly.find(params[:slug])
    @release =
      if params[:version]
        @app.releases.find_by(version: params[:version])
      else
        @app.latest_release
      end

    if @app && @release
      render content_type: 'text/xml', layout: false
    else
      render json: { error: 'No found app or release version' }, status: :not_found
    end
  end
end
