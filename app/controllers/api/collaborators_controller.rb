# frozen_string_literal: true

class Api::CollaboratorsController < Api::BaseController
  before_action :validate_user_token
  before_action :set_app
  before_action :set_collaborator, except: %i[create]

  # GET /api/apps/:app_id/collaborators/:user_id
  def show
    render json: @collaborator
  end

  # POST /api/apps/:app_id/collaborators
  def create
    collaborator = @app.collaborators.find_by(user_id: params[:user_id])
    raise Zealot::Error::RecordExisted.new(model: collaborator) if collaborator

    @collaborator = @app.collaborators.create!(collaborator_params)
    render json: @collaborator, status: :created
  end

  # PUT /api/apps/:app_id/collaborators/:user_id
  def update
    @collaborator.update!(params.permit(:role))
    render json: @collaborator
  end

  # DELETE /api/apps/:app_id/collaborators/:user_id
  def destroy
    @collaborator.destroy!
    render json: { mesage: 'OK' }
  end

  protected

  def set_app
    @app = App.find(params[:app_id])
  end

  def set_collaborator
    @collaborator = @app.collaborators.find_by!(user_id: params[:user_id])
    authorize @collaborator
  end

  def collaborator_params
    @collaborator_params ||= params.permit(:user_id, :role)
  end
end
