# frozen_string_literal: true

class Api::AppsController < Api::BaseController
  include AppArchived

  before_action :validate_user_token
  before_action :set_app, only: %i[show update destroy]

  # GET /api/apps
  def index
    @apps = manage_user? ? App.active : current_user.apps.active
    authorize @apps.first if @apps.present?

    render json: @apps, each_serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  # GET /api/apps/arquived
  def archived
    @apps = manage_user? ? App.archived : current_user.apps.archived
    authorize @apps.first if @apps.present?

    render json: @apps, each_serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  # GET /api/apps/:id
  def show
    relationship = ['schemes.channels']
    relationship << 'collaborators' if manage_user?(app: @app)

    render json: @app, serializer: Api::AppSerializer, include: relationship
  end

  # POST /api/apps
  def create
    @app = App.create!(app_params)
    @app.create_owner(current_user)
    authorize @app

    render json: @app, serializer: Api::AppSerializer, include: 'schemes.channels', status: :created
  end

  # PUT /api/apps/:id
  def update
    raise_if_app_archived!(@app)

    @app.update!(app_params)
    render json: @app, serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  # DELETE /api/apps/:id
  def destroy
    @app.destroy!
    render json: { mesage: 'OK' }
  end

  protected

  def set_app
    @app = App.find(params[:id])
    authorize @app
  end

  def app_params
    @app_params ||= params.permit(:name)
  end
end
