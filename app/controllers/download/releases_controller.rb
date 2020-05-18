class Download::ReleasesController < ApplicationController
  before_action :set_release

  def show
    return render_not_found unless @release && File.exist?(@release.file.path.to_s)

    # 触发 web_hook
    @release.channel.perform_web_hook('download_events')

    headers['Content-Length'] = @release.file.size
    send_file @release.file.path,
              filename: @release.download_filename,
              disposition: 'attachment'
  end

  private

  def set_release
    @release = Release.find(params[:id])
  end

  def render_not_found
    render json: { error: '没有找到应用安装文件' }, status: :not_found
  end
end


