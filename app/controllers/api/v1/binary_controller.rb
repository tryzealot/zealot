class Api::V1::BinaryController < Api::ApplicationController
  def ipa
    file = params.delete :dsym

    FileUtils.mkdir_p 'public/uploads/ipa'

    if file.is_a?(ActionDispatch::Http::UploadedFile)
      File.open("public/uploads/ipa/#{file.original_filename}", 'wb') { |f| f.write(file.read) }
    end

    ios = Ios.create(name: params[:name].to_s.chomp,
                     profile: params[:profile].to_s.chomp,
                     bundle_id: params[:bid].to_s.chomp,
                     version: params[:version].to_s.chomp,
                     build_version: params[:build_version].to_s.chomp,
                     username: params[:user].to_s.chomp,
                     email: params[:email].to_s.chomp,
                     project_path: params[:path].to_s.chomp,
                     dsym_uuid: params[:uuid].to_s.chomp,
                     dsym_file: file.original_filename,
                     last_commit_hash: params[:last_commit_hash].to_s.chomp,
                     last_commit_branch: params[:last_commit_branch].to_s.chomp,
                     last_commit_message: params[:last_commit_message].to_s.chomp,
                     last_commit_author: params[:last_commit_author].to_s.chomp,
                     last_commit_email: params[:last_commit_email].to_s.chomp,
                     last_commit_date: params[:last_commit_date].to_s.chomp,
                     packaged_at: Time.now)

    render json: {
      params: params,
      model: ios.to_json
    }
  end

  def apk
    FileUtils.mkdir_p 'public/uploads/apk'
  end
end
