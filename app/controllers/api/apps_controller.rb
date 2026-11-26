# frozen_string_literal: true

class Api::AppsController < Api::BaseController
  include AppArchived

  before_action :validate_user_token
  before_action :set_app, only: %i[show update destroy]

  # GET /api/apps
  def index
    @apps = app_scopes
    authorize @apps.first if @apps.present?

    render json: @apps, each_serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  # GET /api/apps/archived
  def archived
    @apps = org_scope(App.archived)
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
    @app = App.new(app_params)
    if @app.respond_to?(:organization_id=) && current_org.respond_to?(:persisted?) && current_org.persisted?
      @app.organization_id = current_org.id
    end
    authorize @app
    @app.save!
    @app.create_owner(current_user)

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
    render json: { message: 'OK' }
  end

  protected

  def app_scopes
    base = case params[:scope]
    when 'archived'
      App.archived
    when 'active'
      App.active
    else
      App.all
    end
    org_scope(base)
  end

  def set_app
    @app = org_scope(App).find(params[:id])
    authorize @app
  end

  def app_params
    @app_params ||= params.permit(:name)
  end
end
