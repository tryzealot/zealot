# frozen_string_literal: true

class Api::DebugFiles::DownloadController < Api::BaseController
  before_action :validate_channel_key
  before_action :set_app

  # GET /api/debug_files/download
  def show
    release_version = params[:release_version]
    build_version = params[:build_version]
    order = convert_order(params[:order])

    @debug_file = if both_version?(release_version, build_version)
                    find_by_both_version(release_version, build_version, order)
                  elsif release_version?(release_version, build_version)
                    find_by_releaes_version(order)
                  else
                    find_by_device_type(order)
                  end

    if @debug_file && File.exist?(@debug_file.file.path)
      redirect_to @debug_file.file.url, status: :found
    else
      render json: { error: '没有找到调试文件' }, status: :not_found
    end
  end

  private

  def both_version?(release_version, build_version)
    !release_version.blank? && !build_version.blank?
  end

  def release_version?(release_version, build_version)
    !release_version.blank? && build_version.blank?
  end

  def find_by_both_version(release_version, build_version, order)
    @app.debug_files
        .where(release_version: release_version, build_version: build_version)
        .order(order => :desc)
        .first
  end

  def find_by_releaes_version(release_version, order)
    @app.debug_files
        .where(release_version: release_version)
        .order(order => :desc)
        .first
  end

  def find_by_device_type(order)
    @app.debug_files
        .where(device_type: @channel.device_type)
        .order(order => :desc)
        .first
  end

  def set_app
    @channel.app
  end

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
