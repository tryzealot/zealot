class Api::V1::BinaryController < Api::ApplicationController

  def ipa
    file = params.delete :file

    if file.is_a?(ActionDispatch::Http::UploadedFile)
      # temp_file = Tempfile.new(file.original_filename)

      # temp_file.write file.read
      # file = temp_file
      # temp_file.close


      File.open("public/uploads/ipa//#{file.original_filename}", "wb") { |f| f.write(file.read) }
    end

    render json: {
      params: params
    }
  end

  def apk

  end

end