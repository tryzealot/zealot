# frozen_string_literal: true

class Api::Apps::DownloadController < Api::BaseController
  # GET /api/apps/download
  def show
    @release = Release.find_by_channel params[:slug], params[:version]

    # 触发 web_hook
    @release.channel.perform_web_hook('download_events')

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
