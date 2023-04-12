# frozen_string_literal: true

class DebugFilesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_debug_file, only: %i[show reprocess destroy]

  def index
    @title = t('debug_files.title')
    @apps = App.has_debug_files
    authorize @apps
  end

  def device
    @app = App.find(params[:app_id])
    @debug_files = DebugFile.where(
      app_id: params[:app_id],
      device_type: params[:device]
    ).page(params.fetch(:page, 1)).per(params.fetch(:per_page, Setting.per_page))

    @title = t('.title', app: @app.name, device: params[:device])
  end

  def show
    @app = @debug_file.app
  end

  def reprocess
    DebugFileTeardownJob.perform_later(@debug_file, current_user.id)
    redirect_to debug_file_url(@debug_file), notice: t('.success')
  end

  def new
    @title = t('debug_files.index.upload')
    @apps = App.all
    @debug_file = DebugFile.new
    @debug_file.app_id = params[:app_id] if params[:app_id] && App.find(params[:app_id])
    @debug_file.device_type = params[:device]

    authorize @debug_file
  end

  def create
    @title = t('debug_files.index.upload')
    @debug_file = DebugFile.new(debug_file_params)
    authorize @debug_file

    return render :new, status: :unprocessable_entity unless @debug_file.save

    device_type = DebugFile.device_types[@debug_file.device_type]

    DebugFileTeardownJob.perform_later(@debug_file, current_user.id)
    redirect_to device_app_debug_files_url(@debug_file.app, device_type),
notice: t('activerecord.success.create', key: t('debug_files.title'))
  end

  def destroy
    authorize @debug_file
    @debug_file.destroy
    redirect_to debug_files_url, notice: t('activerecord.success.destroy', key: t('debug_files.title'))
  end

  private

  def set_debug_file
    @debug_file = DebugFile.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def debug_file_params
    params.require(:debug_file).permit(
      :app_id, :device_type, :release_version, :build_version, :file
    )
  end
end
