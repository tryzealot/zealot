class Api::V1::AppController < Api::ApplicationController
  before_filter :validate_params

  def upload
    @app = App.find_or_initialize_by(identifier:params[:identifier])
    if @app.new_record?
      @app.identifier = params[:identifier]
    end
    @app.name = params[:name]
    @app.slug = params[:slug] if params[:slug]
    @app.device_type = params[:device_type]
    @app.user = @user

    if @app.invalid?
      return render json: {
        error: '上次错误，请检查原因！',
        reason: @app.errors.messages
        }, status: 400
    end

    @app.save!

    file = params.delete :file
    fileext = File.extname(file.original_filename)

    if file.is_a?(ActionDispatch::Http::UploadedFile) && [".ipa", ".apk"].include?(fileext)
      @release = @app.releases.create(
        release_version: params[:release_version],
        build_version: params[:build_version],
        identifier: params[:identifier],
        store_url: params[:store_url],
        icon: params[:icon_url],
        changelog: params[:changelog],
        filesize: file.size,
        extra: MultiJson.dump(params)
      )

      storage = Fog::Storage.new({
        :local_root => "public",
        :provider   => 'Local'
      })

      directory = storage.directories.create(
        :key => File.join("uploads", "apps"),
      )

      upload_file = directory.files.create(
        :body => file.read,
        :key  => "#{@app.id.to_s}_#{@release.id.to_s}#{fileext}",
      )

      upload_file.save

      return render json: @app.to_json(include: [:releases])
      {
        app: @app,
        release: @release,
      }
    else
      return render json: {
        error: 'file is not allow file type: ipa/apk'
      }, status: 428
    end
  end

  def info
    @app = App.find_by(slug:params[:slug])
    if @app
      render json: @app.to_json(include: [:releases], except: [:id, :password, :key])
    else

      render json: {
        error: "App is missing",
        params: params
      }, status: 404
    end
  end

  def install_url
    @app = App.find_by(slug:params[:slug])

    @release = if params[:release_id]
      Release.find(params[:release_id])
    else
      @app.releases.last
    end

    if @app && @release
      case @app.device_type.downcase
      when 'iphone', 'ipad', 'ios'
        render 'apps/install_url',
          handlers: [:plist],
          content_type: 'text/xml'
      when 'android'
        redirect_to api_app_download_path(release_id:@release.id)
      end
    else
      render json: {
        error: 'app not had any release'
      }, status: 404
    end
  end

  def download
    @release = Release.find(params[:release_id])

    headers['Content-Length'] = @release.filesize
    send_file @release.file,
      filename: @release.filename,
      type: @release.content_type,
      dispostion: "inline",
      stream: true,
      x_sendfile: true
  end

  private
    def validate_params
      return if ['install_url', 'download'].include?(params[:action])

      @user = User.find_by(key: params[:key])
      unless params.has_key?(:key) && @user
        return render json: {
          error: 'key is invalid'
        }, status: 401
      end
    end
end
