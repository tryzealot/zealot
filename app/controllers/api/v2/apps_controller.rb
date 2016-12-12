class Api::V2::AppsController < ActionController::API
  before_action :set_app, only: [ :show ]

  rescue_from(Exception) do |exception|
    render json: {
      error: exception.message,
      backtrace: exception.backtrace
    }, status: :unprocessable_entity
  end

  def index
    @apps = App.page(1).per(2)
    render json: @apps, each_serializer: Api::AppsSerializer, meta: { page: 1, per_page: 2 }
  end

  def show
    render json: @app, serializer: Api::AppsSerializer
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
end