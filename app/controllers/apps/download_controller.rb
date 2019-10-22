class Apps::DownloadController < ApplicationController
  before_action :set_release

  ##
  # 下载应用
  # GET /apps/:slug/(:version)/qrcode
  def index
    if @release.file&.path && File.exist?(@release.file.path)
      headers['Content-Length'] = @release.file.size
      send_file @release.file.path,
                filename: @release.download_filename,
                disposition: 'attachment'
    else
      render json: { error: 'No found app file' }, status: :not_found
    end
  end

  private

  def set_release
    @release = Release.find params[:release_id]
  end
end
