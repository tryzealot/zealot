# frozen_string_literal: true

class Api::BaseController < ActionController::API
  respond_to :json

  def validate_user_token
    @user = User.find_by(token: params[:token])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '未授权用户' unless @user
  end

  def validate_channel_key
    @channel = Channel.find_by(key: params[:app_key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, '无效的应用渠道 Key' unless @channel
  end

  rescue_from TypeError, with: :render_unmatched_bundle_id_serror
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: :render_unauthorized_user_key
  rescue_from ArgumentError, NoMethodError, PG::Error, with: :render_internal_server_error

  def render_unmatched_bundle_id_serror(exception)
    render json: {
      error: exception.message
    }, status: :unauthorized
  end

  def render_unauthorized_user_key(exception)
    render json: {
      error: exception.message
    }, status: :unprocessable_entity
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
      entry: Rails.env.development? ? exception.backtrace : nil
    }, status: :internal_server_error
  end
end
