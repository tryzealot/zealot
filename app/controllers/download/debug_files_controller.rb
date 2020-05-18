# frozen_string_literal: true

class Download::DebugFilesController < ApplicationController
  before_action :set_debug_file

  def show
    return render_not_found unless @debug_file && File.exist?(@debug_file.file.path.to_s)

    headers['Content-Length'] = @debug_file.file.size
    send_file @debug_file.file.path,
              filename: @debug_file.download_filename,
              disposition: 'attachment'
  end

  private

  def render_not_found
    render json: { error: '没有找到调试文件' }, status: :not_found
  end

  def set_debug_file
    @debug_file = DebugFile.find(params[:id])
  end
end
