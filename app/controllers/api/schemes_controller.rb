# frozen_string_literal: true

class Api::SchemesController < Api::BaseController
  before_action :set_app, only: %i[index create]
  before_action :set_scheme, only: %i[show update destroy]

  # GET /api/apps/:app_id/schemes
  def index
    @schemes = @app.schemes

    render json: @schemes
  end

  # POST /api/apps/:app_id/schemes
  def create
    @scheme = @app.schemes.create!(scheme_params)

    render json: @scheme
  end

  # GET /api/schemes/:id
  def show
    render json: @scheme
  end

  # PUT /api/schemes/:id
  def update
    @scheme.update!(scheme_params)
    render json: @scheme
  end

  # DELETE /api/schemes/:id
  def destroy
    @scheme.destroy!
    render json: {}
  end

  protected

  def set_app
    @app = App.find(params[:app_id])
  end

  def set_scheme
    @scheme = Scheme.find(params[:id])
  end

  def scheme_params
    @scheme_params ||= params.permit(:name, :new_build_callout, :retained_builds)
  end
end
