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

    @release = Release.find_or_initialize_by(
      release_version: params[:release_version],
      build_version: params[:build_version]
    )

    if @release.new_record?
      @release.app = @app
      @release.identifier = params[:identifier]
      @release.changelog = params[:changelog] if params[:changelog]
    end

    render json: @app.to_json(:include => [:releases])
    # {
    #   app: @app,
    #   release: @release,
    # }
  end

  def versions
    render json: {
      error: "App is missing"
    }, status: 403
  end

  def info

    render json: params

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
