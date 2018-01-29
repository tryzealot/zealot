class Api::V2::Apps::VersionsController < API::BaseController
  before_action :validate_user_key, only: [:show]


  def show
    @app = App.find_by(identifier: params[:id])
    @releases = @app.releases.where("release_version > ? AND build_version > ?", params[:release_version], params[:build_version])

    unless @releases.empty?
      render json: @app,
             serializer: Api::AppsSerializer,
             release_version: params[:release_version],
             build_version: params[:build_version]
    else
      render json: {
        error: ''
      }, status: :not_found
    end
  end
end
