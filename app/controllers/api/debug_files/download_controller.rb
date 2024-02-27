# frozen_string_literal: true

class Api::DebugFiles::DownloadController < Api::BaseController
  before_action :validate_channel_key
  before_action :set_app

  # GET /api/debug_files/download
  def show
    release_version = params[:release_version]
    build_version = params[:build_version]
    order = convert_order(params[:order])

    if both_version?(release_version, build_version)
      search_by_both_version(release_version, build_version, order)
    elsif release_version?(release_version, build_version)
      search_by_releaes_version(order)
    else
      search_by_device_type(order)
    end

    return render_not_found unless @debug_file && File.exist?(@debug_file.file.path)

    redirect_to @debug_file.file_url, status: :found
  end

  private

  def render_not_found
    render json: { error: t('api.debug_files.download.default.not_found') }, status: :not_found
  end

  def both_version?(release_version, build_version)
    release_version.present? && build_version.present?
  end

  def release_version?(release_version, build_version)
    release_version.present? && build_version.blank?
  end

  def search_by_both_version(release_version, build_version, order)
    @debug_file = @app.debug_files
                      .where(release_version: release_version, build_version: build_version)
                      .order(order => :desc)
                      .first
  end

  def search_by_releaes_version(release_version, order)
    @debug_file = @app.debug_files
                      .where(release_version: release_version)
                      .order(order => :desc)
                      .first
  end

  def search_by_device_type(order)
    @debug_file = @app.debug_files
                      .where(device_type: @channel.device_type)
                      .order(order => :desc)
                      .first
  end

  def set_app
    @app = @channel.app
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
