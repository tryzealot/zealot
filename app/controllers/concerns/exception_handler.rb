# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :not_found
    rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
    rescue_from ActionController::UnknownFormat, AppInfo::Error, with: :not_acceptable
    rescue_from ActionController::ParameterMissing, CarrierWave::InvalidParameter,
                JSON::ParserError, AppInfo::UnknownFormatError, with: :bad_request
    rescue_from Faraday::Error, OpenSSL::SSL::SSLError,
                TinyAppstoreConnect::ConnectAPIError, with: :internal_server_error
    rescue_from Pundit::NotAuthorizedError, with: :forbidden
  end

  private

  def forbidden(e)
    message = t('errors.messages.not_authorized_policy', query: e.query, model: e.record.class)
    new_exception = StandardError.new(message)
    new_exception.set_backtrace(e.backtrace)

    respond_with_error(403, new_exception)
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
    respond_with_error(500, e)
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
      @title = t("errors.code.#{@code}.title")
      @message = exception.message if code < 500

      format.any  { render 'errors/index', status: code, formats: [:html] }
      format.json { render json: { code: code, error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code }
    end
  end
end
