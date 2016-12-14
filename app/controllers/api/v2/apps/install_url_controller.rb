class Api::V2::Apps::InstallUrlController < ActionController::API
  def show
    @app = App.friendly.find(params[:slug])
    @release = @app.releases.find_by(version: params[:version])

    if @app && @release
      render content_type: 'text/xml', layout: false
    else
      render json: { error: 'No found app or release version' }, status: :not_found
    end
  end
end
