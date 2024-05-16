class CollaboratorsController < ApplicationController
  before_action :set_app
  before_action :set_collaborator, only: %i[ edit update destroy ]

  # GET /apps/:app_id/collaborators/new
  def new
    @collaborator = @app.collaborators.build
  end

  # POST /apps/:app_id/collaborators
  def create
    @collaborator = @app.collaborators.new(collaborator_params)

    if @collaborator.save
      redirect_to @app, notice: "Collaborator was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /collaborators/1/edit
  def edit
  end

  # PATCH/PUT /collaborators/1
  def update
    if @collaborator.update(collaborator_params)
      redirect_to @collaborator.app, notice: "Collaborator was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /collaborators/1
  def destroy
    app = @collaborator.app
    @collaborator.destroy!
    redirect_to app, notice: "Collaborator was successfully destroyed.", status: :see_other
  end

  private

  def set_app
    @app = App.find(params[:app_id])
  end

  def set_collaborator
    @collaborator = Collaborator.find_by(
      app_id: params[:app_id],
      user_id: params[:id]
    )
  end

  # Only allow a list of trusted parameters through.
  def collaborator_params
    params.require(:collaborator).permit(:user_id, :app_id, :role)
  end
end
