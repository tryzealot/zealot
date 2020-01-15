# frozen_string_literal: true

class Api::Apps::DownloadController < Api::BaseController
  # GET /api/apps/download
  def show
    @release = Release.version_by_channel(params[:slug], params[:version])

    return render_not_found unless @release && File.exist?(@release.file.path)

    # 触发 web_hook
    @release.channel.perform_web_hook('download_events')

    headers['Content-Length'] = @release.file.size
    send_file @release.file.path,
              filename: @release.download_filename,
              disposition: 'attachment'
  end

  private

  def render_not_found
    render json: { error: '没有找到应用安装文件' }, status: :not_found
  end
end
