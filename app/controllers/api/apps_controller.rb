# frozen_string_literal: true

class Api::AppsController < Api::BaseController
  before_action :validate_user_token
  before_action :set_app, only: %i[show]

  # GET /api/apps
  def index
    @apps = App.all
    render json: @apps, each_serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  # GET /api/apps/:id
  def show
    render json: @app, serializer: Api::AppSerializer, include: 'schemes.channels'
  end

  protected

  def set_app
    @app = App.find(params[:id])
  end
end
