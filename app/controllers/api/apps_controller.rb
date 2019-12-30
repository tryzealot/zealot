# frozen_string_literal: true

require 'app-info'
class Api::AppsController < ActionController::API
  before_action :set_app, only: [:show]

  rescue_from(Exception) do |exception|
    render json: {
      error: exception.message,
      backtrace: exception.backtrace
    }, status: :unproceswsable_entity
  end

  def index
    @apps = App.all
    render json: @apps, each_serializer: Api::AppsSerializer, meta: { page: 1, per_page: 10 }
  end

  def show
    render json: @app, serializer: Api::AppsSerializer, release_version: @app.releases.last.version
  end

  protected

  def set_app
    @app = App.find(params[:id])
  end
end
