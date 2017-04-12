class Api::V2::Pacs::UpdateController < ActionController::API
  before_action :validate_pac_id

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ArgumentError, with: :render_internal_server_error

  def create
    return render status: :not_modified if @pac.host == params[:host] && @pac.port == params[:port]

    @pac.update!(pac_params)
    raise ActiveRecord::RecordInvalid, @pac unless @pac.valid?(:api)

    render json:{}, status: :accepted
  end

  private

  def render_not_found(exception)
    render json: {
      error: 'not found pac'
    }, status: :not_found
  end

  def render_unprocessable_entity_response(exception)
    render json: {
      error: 'host and port could not be upload with errors',
      reason: exception.record.errors
    }, status: :unprocessable_entity
  end

  def render_internal_server_error(exception)
    render json: {
      error: exception.message,
      entry: exception.backtrace
    }, status: :internal_server_error
  end

  def pac_params
    params.permit(:host, :port)
  end

  def validate_pac_id
    @pac = Pac.find(params[:id])
  end
end
