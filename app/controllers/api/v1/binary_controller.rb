class Api::V1::BinaryController < Api::ApplicationController

  def ipa
    file = params.delete :dsym

    FileUtils.mkdir_p "public/uploads/ipa"

    if file.is_a?(ActionDispatch::Http::UploadedFile)
      File.open("public/uploads/ipa/#{file.original_filename}", "wb") { |f| f.write(file.read) }
    end

    ios = Ios.create({
      name: params[:name],
      bundle_id: params[:bid],
      version: params[:version],
      project_path: params[:path],
      dsym_file: file.original_filename,
      packaged_at: Time.now
    })

    render json: {
      params: params,
      model: ios.to_json
    }
  end

  def apk
    FileUtils.mkdir_p "public/uploads/apk"
  end

end