require 'app-info'

class Api::V2::AppsController < ActionController::API
  before_action :set_app, only: [:show]

  rescue_from(Exception) do |exception|
    render json: {
      error: exception.message,
      backtrace: exception.backtrace
    }, status: :unproceswsable_entity
  end

  def index
    @apps = App.page(1).per(10)
    render json: @apps, each_serializer: Api::AppsSerializer, meta: { page: 1, per_page: 10 }
  end

  def show
    render json: @app, serializer: Api::AppsSerializer, release_version: @app.releases.last.version
  end

  protected

  def set_app
    @app =
      case params[:id].to_i
      when Integer
        App.find(params[:id])
      else
        App.find_by(identifier: params[:id])
      end
  end

  def validate_app_key
    @app = App.find_by(identifier: params[:id], key: params[:key])
    return if @app

    render json: {
      error: '未授权或无效的 App Key'
    }, status: 401
  end
end
