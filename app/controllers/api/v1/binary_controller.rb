class Api::V1::BinaryController < Api::ApplicationController

  def ipa
    file = params.delete :dsym

    FileUtils.mkdir_p "public/uploads/ipa"

    if file.is_a?(ActionDispatch::Http::UploadedFile)
      File.open("public/uploads/ipa/#{file.original_filename}", "wb") { |f| f.write(file.read) }
    end

    render json: {
      params: params
    }
  end

  def apk
    FileUtils.mkdir_p "public/uploads/apk"
  end

end