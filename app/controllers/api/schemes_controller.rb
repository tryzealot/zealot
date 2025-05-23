# frozen_string_literal: true

class Api::SchemesController < Api::BaseController
  include AppArchived

  before_action :validate_user_token
  before_action :set_app, only: %i[index create]
  before_action :set_scheme, only: %i[show update destroy]

  # GET /api/apps/:app_id/schemes
  def index
    @schemes = @app.schemes
    raise ActiveRecord::RecordNotFound, t('api.schemes.index.not_found', id: @app.id) if @schemes.blank? 

    authorize @schemes.first
    render json: @schemes
  end

  # POST /api/apps/:app_id/schemes
  def create
    raise_if_app_archived!(@app)

    @scheme = @app.schemes.create!(scheme_params)
    authorize @scheme

    render json: @scheme
  end

  # GET /api/schemes/:id
  def show
    render json: @scheme
  end

  # PUT /api/schemes/:id
  def update
    raise_if_app_archived!(@scheme.app)

    @scheme.update!(scheme_params)
    render json: @scheme
  end

  # DELETE /api/schemes/:id
  def destroy
    raise_if_app_archived!(@scheme.app)

    @scheme.destroy!
    render json: { mesage: 'OK' }
  end

  protected

  def set_app
    @app = App.find(params[:app_id])
    authorize @app
  end

  def set_scheme
    @scheme = Scheme.find(params[:id])
    authorize @scheme
  end

  def scheme_params
    @scheme_params ||= params.permit(:name, :new_build_callout, :retained_builds)
  end
end
