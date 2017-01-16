class Api::V2::Apps::UploadController < ActionController::API
  before_action :validate_user_key

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: :render_unauthorized_user_key
  rescue_from ArgumentError, with: :render_internal_server_error

  def create
    create_or_update_app
    create_or_update_release

    perform_app_web_hook_job
    # perform_app_teardown_job

    render json: @app,
           serializer: Api::AppsSerializer,
           status: @new_record ? :created : :ok
  end

  private

  def render_unprocessable_entity_response(exception)
    render json: {
      error: 'app could not be upload with errors',
      reason: exception.record.errors
    }, status: :unprocessable_entity
  end

  def render_unauthorized_user_key(exception)
    render json: {
      error: exception.message
    }, status: :unauthorized
  end

  def render_internal_server_error(exception)
    render json: {
      error: exception.message,
      entry: exception.backtrace
    }, status: :internal_server_error
  end

  def create_or_update_app
    if app_new_record?
      @app = App.new(app_params)
      @app.user = @user
      @app.save!
    else
      @app.update!(app_params)
    end
  end

  def create_or_update_release
    if release_new_record?
      @release = Release.new(release_params)
      @release.app = @app
      @release.save!
    end

    # 更新 app 的数据并用于 json 显示
    @app = @release.app
  end

  def app_new_record?
    @app = App.find_or_initialize_by(identifier: params[:identifier])
    @new_record ||= @app.new_record?
  end

  def release_new_record?
    release_find_by_params =
      if params[:last_commit].blank?
        params.permit(:release_version, :build_version)
      else
        params.permit(:release_version, :build_version, :last_commit)
      end

    @release = @app.releases.find_or_initialize_by(release_find_by_params)
    @new_record = @release.new_record?
  end

  def perform_app_web_hook_job
    web_hooks = WebHook.where(upload_events: 1, app: @app)
    return if web_hooks.empty?

    web_hooks.each do |web_hook|
      AppWebHookJob.perform_later 'upload_events', web_hook
    end
  end

  def perform_app_teardown_job
    AppTeardownJob.perform_later 'app_teardown', @release
  end

  def param_extra
    return @extra if @extra

    extra = params.clone.to_unsafe_h
    extra.delete(:file)
    extra.delete(:icon) if extra.key?(:icon)

    @extra ||= extra
  end

  def param_devices
    @devices = JSON.dump(params[:devices])
    @devices = nil if @devices.size.zero?
  rescue
    @device = nil
  end

  def app_params
    params.permit(:identifier, :name, :slug, :device_type, :jenkins_job, :git_url)
  end

  def release_params
    attributes = params.permit(:identifier, :release_version, :build_version, :changelog, :channel, :branch, :last_commit, :ci_url, :file, :icon, :extra, :devices, :release_type)
    attributes[:devices] = param_devices
    attributes[:extra] = JSON.dump(param_extra)

    attributes
  end

  def validate_user_key
    @user = User.find_by(key: params[:key])
    raise ActionCable::Connection::Authorization::UnauthorizedError, 'unauthorized user key' unless @user
  end
end
