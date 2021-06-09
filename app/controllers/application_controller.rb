# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token

  before_action :set_sentry_context

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from ActionController::UnknownFormat, with: :not_acceptable
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from HTTP::Error, OpenSSL::SSL::SSLError, with: :internal_server_error
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def set_sentry_context
    Sentry.set_user(id: session[:current_user_id])
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end

  def forbidden(e)
    respond_with_error(403, e)
  end

  def not_found(e)
    respond_with_error(404, e)
  end

  def gone(e)
    respond_with_error(410, e)
  end

  def unprocessable_entity(e)
    respond_with_error(422, e)
  end

  def not_acceptable(e)
    respond_with_error(406, e)
  end

  def bad_request(e)
    respond_with_error(400, e)
  end

  def internal_server_error(e)
    respond_with_error(500)
  end

  def service_unavailable(e)
    respond_with_error(503, e)
  end

  def respond_with_error(code, exception)
    if code >= 500
      logger.error exception.full_message
      Sentry.capture_exception exception
    end

    respond_to do |format|
      @code = code
      @exception = exception
      @title = t("errors.#{@code}.title")
      format.any  { render 'errors/index', status: code, formats: [:html] }
      format.json { render json: { code: code, error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code }
    end
  end
end
