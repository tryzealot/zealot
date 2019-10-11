class DebugFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_debug_file, only: [:show, :edit, :update, :destroy]
  before_action :set_app_list, only: [:new, :create]

  def index
    @title = 'Debug File 列表'
    @debug_files = DebugFile.all.order(id: :desc)
  end

  def new
    @title = '上传 Debug File 文件'
    @debug_file = DebugFile.new
  end

  def create
    @title = '上传 Debug File 文件'
    @debug_file = DebugFile.new(debug_file_params)

    if @debug_file.save
      redirect_to debug_file_url, notice: 'Debug File 上传成功'
    else
      render :new
    end
  end

  def destroy
    @debug_file.destroy
    redirect_to debug_file_url, notice: 'Debug File 删除成功'
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

  def set_app_list
    @apps = App.all
  end
end
