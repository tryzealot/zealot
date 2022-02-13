# frozen_string_literal: true

class Download::DebugFilesController < ApplicationController
  before_action :set_debug_file

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response

  def show
    return render_not_found_entity_response unless File.exist?(@debug_file.file.path.to_s)

    redirect_to filename_download_debug_file_url(@debug_file, @debug_file.download_filename)
  end

  def download
    headers['Content-Length'] = @debug_file.file.size
    send_file @debug_file.file.path,
              filename: @debug_file.download_filename,
              disposition: 'attachment'
  end

  private

  def render_not_found_entity_response
    render json: {
      error: t('.not_found')
    }, status: :not_found
  end

  def set_debug_file
    authorize @debug_file = DebugFile.find(params[:id])
  end
end
