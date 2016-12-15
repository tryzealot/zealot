class Api::V2::Apps::LatestController < ActionController::API
  before_action :validate_app_key, only: [:show]

  def show
    render json: @app, serializer: Api::AppsSerializer
  end

  def validate_app_key
    @app = App.find_by(identifier: params[:id], key: params[:key])
    return if @app

    render json: {
      error: '未授权或无效的 App Key'
    }, status: 401
  end
end
