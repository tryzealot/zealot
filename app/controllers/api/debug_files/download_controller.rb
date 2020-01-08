# frozen_string_literal: true

class Api::DebugFiles::DownloadController < Api::BaseController
  before_action :validate_channel_key, only: [:show]

  # GET /api/debug_files/download
  def show
    release_version = params[:release_version]
    build_version = params[:build_version]
    order = convert_order(params[:order])

    @app = @channel.app
    @debug_file = if !release_version.blank? && !build_version.blank?
                    @app.debug_files
                        .where(release_version: release_version, build_version: build_version)
                        .order(order => :desc)
                        .first
                  elsif !release_version.blank? && build_version.blank?
                    @app.debug_files
                        .where(release_version: release_version)
                        .order(order => :desc)
                        .first
                  else
                    @app.debug_files
                        .where(device_type: @channel.device_type)
                        .order(order => :desc)
                        .first
                  end

    if @debug_file && File.exist?(@debug_file.file.path)
      redirect_to @debug_file.file.url, status: :found
    else
      render json: { error: '没有找到调试文件' }, status: :not_found
    end
  end

  private

  def convert_order(value)
    value == 'upload' ? :id : :build_version
  end

  def use_lastest_version?(version)
    version == 'latest'
  end

  def debug_file_params
    params.permit(
      :release_version, :build_version, :file
    )
  end
end
