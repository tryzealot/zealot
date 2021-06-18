# frozen_string_literal: true

class Api::BaseController < ActionController::API
  respond_to :json

  before_action :set_cache_headers

  rescue_from TypeError, with: :render_unmatched_bundle_id_serror
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: :render_unauthorized_user_key
  rescue_from ArgumentError, NoMethodError, PG::Error, with: :render_internal_server_error
  rescue_from ActionController::ParameterMissing, with: :render_missing_params_error

  before_action :record_page_view

  def validate_user_token
    @user = User.find_by(token: params[:token])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '未授权用户' unless @user
  end

  def validate_channel_key
    @channel = Channel.find_by(key: params[:channel_key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '无效的应用渠道 Key' unless @channel
  end

  def render_not_found_entity_response(exception)
    logger_error exception
    render json: {
      error: exception.message
    }, status: :not_found
  end

  def render_missing_params_error(exception)
    logger_error exception
    render json: {
      error: exception.message
    }, status: :unprocessable_entity
  end

  def render_unmatched_bundle_id_serror(exception)
    logger_error exception
    render json: {
      error: exception.message,
    }, status: :unauthorized
  end

  def render_unauthorized_user_key(exception)
    logger_error exception
    render json: {
      error: exception.message
    }, status: :unprocessable_entity
  end

  def render_unprocessable_entity_response(exception)
    render json: {
      error: '参数错误，请检查请求的参数是否正确',
      entry: exception.record.errors
    }, status: :unprocessable_entity
  end

  def render_internal_server_error(exception)
    logger_error exception
    render json: {
      error: exception.message
    }, status: :internal_server_error
  end

  private

  def record_page_view
    ActiveAnalytics.record_request(request)
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
  end

  def logger_error(exception)
    return unless Rails.env.development?

    logger.error exception.full_message
  end
end
