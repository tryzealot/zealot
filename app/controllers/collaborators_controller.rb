# frozen_string_literal: true

class CollaboratorsController < ApplicationController
  before_action :set_app
  before_action :set_collaborator, only: %i[ edit update destroy ]

  # GET /apps/:app_id/collaborators/new
  def new
    @title = t('.title')
    @collaborator = @app.collaborators.build
    authorize @collaborator
  end

  # POST /apps/:app_id/collaborators
  def create
    @collaborator = @app.collaborators.new(collaborator_params)
    authorize @collaborator

    if @collaborator.save
      key = "#{@collaborator.user.username} #{t('collaborators.default.title')}"
      redirect_to @app, notice: t('activerecord.success.create', key: key)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /collaborators/1/edit
  def edit
    @title = t('.title')
  end

  # PATCH/PUT /collaborators/1
  def update
    if @collaborator.update(collaborator_params)
      notice = t('activerecord.success.update', key: t('collaborators.default.title'))
      redirect_to @collaborator.app, notice: notice, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /collaborators/1
  def destroy
    app = @collaborator.app
    @collaborator.destroy!

    notice = t('activerecord.success.destroy', key: t('collaborators.default.title'))
    redirect_to app, notice: notice, status: :see_other
  end

  private

  def set_app
    @app = App.find(params[:app_id])
  end

  def set_collaborator
    @collaborator = Collaborator.find_by(
      app_id: params[:app_id],
      user_id: params.extract_value(:id)
    )
    authorize @collaborator
  end

  # Only allow a list of trusted parameters through.
  def collaborator_params
    params.require(:collaborator).permit(:user_id, :app_id, :role)
  end
end
