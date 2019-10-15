class DebugFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_debug_file, only: [:show, :edit, :update, :destroy]

  def index
    @title = 'Debug File 列表'
    @apps = App.avaiable_debug_files
  end

  def new
    @title = '上传 Debug File 文件'
    @apps = App.all
    @debug_file = DebugFile.new
  end

  def create
    @title = '上传 Debug File 文件'
    @debug_file = DebugFile.new(debug_file_params)

    if @debug_file.save
      DebugFileTeardownJob.perform_later @debug_file

      redirect_to debug_files_url, notice: 'Debug File 上传成功，后台正在解析文件请稍后查看详情'
    else
      render :new
    end
  end

  def destroy
    @debug_file.destroy
    redirect_to debug_files_url, notice: 'Debug File 删除成功'
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
