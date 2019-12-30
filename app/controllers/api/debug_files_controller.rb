# frozen_string_literal: true

require 'app-info'
class Api::DebugFilesController < Api::BaseController
  before_action :validate_user_token
  before_action :validate_channel_key, only: [:index, :create]
  before_action :set_debug_file, only: [:show, :destroy]

  def index
    @debug_files = DebugFile.where(app: @channel.app)
      .page(params.fetch(:page, 1).to_i)
      .per(params.fetch(:per_page, 10).to_i)
      .order(id: :desc)

    @debug_files = @debug_files.where(device_type: @channel.device_type)

    render json: @debug_files, each_serializer: Api::DebugFileSerializer
  end

  def show
    render json: @debug_file, serializer: Api::DebugFileSerializer
  end

  def create
    @debug_file = DebugFile.new(debug_file_params)
    @debug_file.app = @channel.app
    @debug_file.device_type = @channel.device_type
    if @debug_file.save!
      DebugFileTeardownJob.perform_now @debug_file
      render json: @debug_file, serializer: Api::DebugFileSerializer, status: 201
    else
      render json: @debug_file.errors
    end
  end

  def update
    @debug_file.update(debug_file_params)
  end

  def destroy
    @debug_file.destroy
    render json: { mesage: 'OK' }
  end

  protected

  def set_debug_file
    @debug_file = DebugFile.find(params[:id])
  end

  def debug_file_params
    params.permit(
      :release_version, :build_version, :file
    )
  end
end
