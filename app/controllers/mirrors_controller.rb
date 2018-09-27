require 'cgi'

class MirrorsController < ApplicationController
  FILESIZE_FORMAT = [
    ['%.1fT', 1 << 40],
    ['%.1fG', 1 << 30],
    ['%.1fM', 1 << 20],
    ['%.1fK', 1 << 10],
  ]

  # GET /mirrors
  def index
    @title = "软件列表"
    @mirrors = files(params[:directory])
  end

  # GET /mirrors/download/?file=1
  def download
    file = params[:file]
    if file_exist?(file)
      info = file_info(File.join(mirror_path, file))
      headers['Content-Length'] = info[:size]
      send_file info[:full_path],
                filename: info[:name],
                disposition: 'attachment'
    else
      render json: { error: 'No found app file' }, status: :not_found
    end
  end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_mirror
  #     @mirror = Mirror.find(params[:id])
  #   end

  #   # Only allow a trusted parameter "white list" through.
  #   def mirror_params
  #     params.fetch(:mirror, {})
  #   end

  private
    def files(path = nil)
      path = path ? File.join(mirror_path, path) : mirror_path
      Dir.glob(File.join(path, "*")).each_with_object([]) do |file, obj|
        obj << file_info(file)
      end
    end

    def filesize_format(int)
      FILESIZE_FORMAT.each do |format, size|
        return format % (int.to_f / size) if int >= size
      end

      "#{int}B"
    end

    def file_exist?(file)
      File.exist?(File.join(mirror_path, file))
    end

    def file_info(file)
      {
        name: File.basename(file),
        path: file.sub("#{mirror_path}/", ''),
        full_path: file,
        type: File.file?(file) ? 'file' : 'directory',
        size: filesize_format(File.size(file)),
        updated_at: File.stat(file).mtime
      }
    end

    def mirror_path
      @mirror_path ||= File.join(Rails.public_path, "mirrors")
    end
end
