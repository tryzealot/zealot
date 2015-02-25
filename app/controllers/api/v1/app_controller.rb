class Api::V1::AppController < Api::ApplicationController
  before_filter :validate_params

  def upload
    @app = App.find_or_initialize_by(identifier:params[:identifier])
    if @app.new_record?
      @app.identifier = params[:identifier]
      @app.name = params[:name]
      @app.slug = params[:slug] if params[:slug]
      @app.device_type = params[:device_type]
    end

    if @app.invalid?
      return render json: {
        error: 'upload failed',
        reason: @app.errors.messages
        }, status: 400
    end

    @app.save!


    file = params.delete :dsym
    if file.is_a?(ActionDispatch::Http::UploadedFile)
      storage = Fog::Storage.new({
        :local_root => "public/uploads/apps",
        :provider   => 'Local'
      })

      directory = storage.directories.create(
        :key => params[:device_type].downcase,

      )

      file = directory.files.create(
        :body => file,
        :key  => file.original_filename
      )

      File.open("public/uploads/ipa/#{file.original_filename}", "wb") { |f| f.write(file.read) }
    end


    storage

    @release = Release.find_or_initialize_by(
      release_version: params[:release_version],
      build_version: params[:build_version]
    )

    if @release.new_record?
      @release.app = @app
      @release.identifier = params[:identifier]
      @release.changelog = params[:changelog] if params[:changelog]
    end

    render json: @app.to_json(include: [:releases])
    # {
    #   app: @app,
    #   release: @release,
    # }
  end

  def info
    @app = App.find_by(slug:params[:slug])
    if @app
      render json: @app.to_json(include: [:releases], except: [:id, :password, :key])
    else

      render json: {
        error: "App is missing",
        params: params
      }, status: 403
    end
  end

  def install_url
    render json: params
  end

  private
    def validate_params
      @user = User.find_by(key: params[:key])
      unless params.has_key?(:key) && @user
        return render json: {
          error: 'key is invalid'
        }, status: 400
      end
    end
end
