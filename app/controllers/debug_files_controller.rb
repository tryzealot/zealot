# frozen_string_literal: true

class DebugFilesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show legacy_show]
  before_action :set_app, except: :legacy_show
  before_action :set_debug_file, only: %i[show destroy reprocess]

  def index
    authorize DebugFile.new(app: @app), :index?

    @title = t('debug_files.title')
    @proguard_files = @app.android_debug_files.page(params[:proguard_page]).per(Setting.per_page)
    @dsym_files = @app.ios_debug_files.page(params[:dsym_page]).per(Setting.per_page)
  end

  def show
    @title = t('debug_files.show.title',
      device: helpers.platform_name(@debug_file.device_type),
      version: helpers.debug_file_version(@debug_file))
  end

  def new
    @title = t('debug_files.index.upload')
    device_type = params[:device_type] if DebugFile.device_types.key?(params[:device_type])
    @debug_file = @app.debug_files.new(device_type: device_type)
    authorize @debug_file
  end

  def create
    @title = t('debug_files.index.upload')
    @debug_file = @app.debug_files.new(debug_file_params)
    authorize @debug_file

    return render :new, status: :unprocessable_entity unless @debug_file.save

    DebugFileTeardownJob.perform_later(@debug_file, current_user.id)
    redirect_to app_debug_files_url(@app, anchor: platform_anchor(@debug_file)),
                notice: t('activerecord.success.create', key: t('debug_files.title'))
  end

  def destroy
    anchor = platform_anchor(@debug_file)
    @debug_file.destroy
    redirect_to app_debug_files_url(@app, anchor: anchor),
                notice: t('activerecord.success.destroy', key: t('debug_files.title'))
  end

  def reprocess
    DebugFileTeardownJob.perform_later(@debug_file, current_user.id)
    redirect_to app_debug_file_url(@app, @debug_file), notice: t('.success')
  end

  # Old /debug_files/:id URLs, kept as a permanent redirect to the app scope.
  def legacy_show
    debug_file = DebugFile.find(params[:id])
    authorize debug_file, :show?
    redirect_to app_debug_file_path(debug_file.app, debug_file), status: :moved_permanently
  end

  private

  def set_app
    @app = App.find(params[:app_id])
  end

  def set_debug_file
    @debug_file = @app.debug_files.find(params[:id])
    authorize @debug_file
  end

  def platform_anchor(debug_file)
    helpers.ios_debug_file?(debug_file) ? 'dsym' : 'proguard'
  end

  # Only allow a trusted parameter "white list" through. The app always comes
  # from the URL, so it is not accepted from the form.
  def debug_file_params
    params.require(:debug_file).permit(
      :device_type, :release_version, :build_version, :file
    )
  end
end
