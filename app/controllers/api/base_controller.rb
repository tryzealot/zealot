# frozen_string_literal: true

class Api::BaseController < ActionController::API
  include ActionView::Helpers::TranslationHelper
  respond_to :json

  before_action :set_cache_headers

  rescue_from TypeError, with: :render_unmatched_bundle_id_serror
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionCable::Connection::Authorization::UnauthorizedError,
              with: :render_unauthorized_user_key
  rescue_from ActiveRecord::RecordNotSaved, ArgumentError, NoMethodError,
              PG::Error, with: :render_internal_server_error
  rescue_from ActionController::ParameterMissing, CarrierWave::InvalidParameter,
              AppInfo::UnknownFormatError, with: :render_missing_params_error
  rescue_from ActionController::UnknownFormat, with: :not_acceptable
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity

  def validate_user_token
    @user = User.find_by(token: params[:token])
    raise ActionCable::Connection::Authorization::UnauthorizedError, t('api.unauthorized_token') unless @user
  end

  def validate_channel_key
    @channel = Channel.find_by(key: params[:channel_key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, t('api.unauthorized_channel_key') unless @channel
  end

  def record_invalid(e)
    respond_with_error(
      :unprocessable_entity, e,
      error: t('api.unprocessable_entity'),
      entry: e.record.errors
    )
  end

  def not_acceptable(e)
    respond_with_error(:not_acceptable, e)
  end

  def unprocessable_entity(e)
    respond_with_error(:unprocessable_entity, e)
  end

  def render_not_found_entity_response(e)
    respond_with_error(:not_found, e)
  end

  def render_missing_params_error(e)
    respond_with_error(:unprocessable_entity, e)
  end

  def render_unmatched_bundle_id_serror(e)
    respond_with_error(:unauthorized, e)
  end

  def render_unauthorized_user_key(e)
    respond_with_error(:unprocessable_entity, e)
  end

  def render_internal_server_error(e)
    respond_with_error(:internal_server_error, e)
  end

  private

  def respond_with_error(code, e, **body)
    logger_error e
    body[:error] ||= e.message
    if Rails.env.development?
      body[:debug] = {
        class: e.class.name,
        backtrace: e.backtrace
      }
    end

    render json: body, status: code
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
  end

  def logger_error(e)
    return unless Rails.env.development?

    logger.error e.full_message
  end
end
