# frozen_string_literal: true

class CollaboratorsController < ApplicationController
  include AppArchived

  before_action :set_app
  before_action :set_collaborator, only: %i[ edit update destroy ]

  # GET /apps/:app_id/collaborators/new
  def new
    raise_if_app_archived!(@app)

    @title = t('.title')
    @collaborator = @app.collaborators.build
    authorize @collaborator
  end

  # POST /apps/:app_id/collaborators
  def create
    raise_if_app_archived!(@app)

    @collaborator = @app.collaborators.new(collaborator_params)
    authorize @collaborator

    @collaborator.owner = true if @app.collaborators.count.zero?
    return render :new, status: :unprocessable_entity unless @collaborator.save

    key = "#{@collaborator.user.username} #{t('collaborators.default.title')}"
    flash.now.notice = t('activerecord.success.create', key: key)
    respond_to do |format|
      format.html { redirect_to @app }
      format.turbo_stream
    end
  end

  # GET /collaborators/1/edit
  def edit
    raise_if_app_archived!(@app)

    @title = t('.title')
  end

  # PATCH/PUT /collaborators/1
  def update
    raise_if_app_archived!(@app)
    return render :edit, status: :unprocessable_entity unless @collaborator.update(collaborator_params)

    notice = t('activerecord.success.update', key: t('collaborators.default.title'))
    flash.now.notice = notice
    respond_to do |format|
      format.html { redirect_to @app }
      format.turbo_stream
    end
  end

  # DELETE /collaborators/1
  def destroy
    raise_if_app_archived!(@app)
    
    app = @collaborator.app
    @collaborator.destroy!

    notice = t('activerecord.success.destroy', key: t('collaborators.default.title'))
    flash.now.notice = notice
    respond_to do |format|
      format.html { redirect_to app }
      format.turbo_stream
    end
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
