class Api::V2::Apps::DownloadController < Api::BaseController
  def show
    @release = Release.find_by_channel params[:slug], params[:version]

    if @release && File.exist?(@release.file.path)
      headers['Content-Length'] = @release.file.size
      send_file @release.file.path,
                filename: @release.download_filename,
                disposition: 'attachment'
    else
      render json: { error: 'No found app file' }, status: :not_found
    end
  end
end
