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


    file_md5 = Digest::MD5.hexdigest(params[:file].tempfile.read.to_s)

    status = 200
    @release = @app.releases.find_by(
      identifier: params[:identifier],
      release_version: params[:release_version],
      build_version: params[:build_version],
      md5: file_md5
    )

    unless @release
      status = 201

      extra = params.clone
      extra.delete(:file)
      @release = @app.releases.create(
        identifier: params[:identifier],
        release_version: params[:release_version],
        build_version: params[:build_version],
        store_url: params[:store_url],
        icon: params[:icon_url],
        changelog: params[:changelog],
        file: params[:file],
        extra: MultiJson.dump(extra)
      )
    end

    return render json: @release.to_json(include: [:app]), status: status
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
    send_file @release.file.path,
      filename: @release.file.filename,
      disposition: 'inline'
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
