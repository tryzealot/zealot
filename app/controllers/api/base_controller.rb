class Api::BaseController < ActionController::API
  respond_to :json

  def validate_user_key
    @user = User.find_by(key: params[:key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '未授权用户' unless @user
  end

  def validate_app_key
    @app = App.find_by(key: params[:key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '无效的 App Key' unless @app
  end

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: :render_unauthorized_user_key
  rescue_from ArgumentError, NoMethodError, Mysql2::Error, with: :render_internal_server_error

  def render_unauthorized_user_key(exception)
    render json: {
      error: exception.message
    }, status: :unauthorized
  end

  def render_unprocessable_entity_response(exception)
    render json: {
      error: 'resource could not be processed with errors',
      entry: Rails.env.development? ? exception.record.errors : nil
    }, status: :unprocessable_entity
  end

  def render_internal_server_error(exception)
    render json: {
      error: exception.message,
      entry: exception.backtrace
    }, status: :internal_server_error
  end
end