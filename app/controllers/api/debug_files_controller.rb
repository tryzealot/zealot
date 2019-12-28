require 'app-info'
class Api::DebugFilesController < Api::BaseController
  before_action :validate_user_token
  before_action :validate_channel_key, only: [:index, :create]

  def index
    @debug_files = DebugFile.where(app: @channel.app)
    @debug_files = @debug_files.where(device_type: @channel.device_type)

    render json: {debug_files: @debug_files, channel: @channel} #, each_serializer: Api::AppsSerializer, meta: { page: 1, per_page: 10 }
  end

  def show
    @debug_file = DebugFile.find params[:id]
    render json: @debug_file
  end

  def create
    @debug_file = DebugFile.new(debug_file_params)
    @debug_file.app = @channel.app
    @debug_file.device_type = @channel.device_type
    if @debug_file.save!
      DebugFileTeardownJob.perform_now @debug_file
      render json: @debug_file
    else
      render json: @debug_file.errors
    end
  end

  protected

  def set_app
    @app = App.find(params[:id])
  end

  def debug_file_params
    params.permit(
      :release_version, :build_version, :file
    )
  end
end
