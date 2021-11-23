# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = { current_user: current_user }
    result = ZealotSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, t('errors.messages.unexpected_parameter', value: ambiguous_param)
    end
  end

  def handle_error_in_development(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    render json: {
      error: {
        message: exception.message,
        backtrace: exception.backtrace
      },
      data: {}
    }, status: :internal_server_error
  end
end
