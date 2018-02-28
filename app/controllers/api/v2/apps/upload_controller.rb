class Api::V2::Apps::UploadController < API::BaseController
  before_action :validate_user_key

  def create
    create_or_update_app
    create_or_update_release
    perform_app_web_hook_job

    render json: @app,
           serializer: Api::AppsSerializer,
           status: @new_record ? :created : :ok
  end

  private

  def create_or_update_app
    if app_new_record?
      @app = App.new(app_params)
      @app.save!
    else
      @app.update!(app_params)
    end
  end

  def create_or_update_release
    if release_new_record?
      @release = Release.new(release_params)
      @release.app = @app
      @release.user = @user
      @release.save!
    end

    @app = App.find_by_release(@release)
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

  def release_params
    attributes = params.permit(
      :identifier, :release_version, :build_version,
      :changelog, :channel, :branch, :last_commit, :ci_url,
      :file, :icon, :extra, :devices, :release_type
    )

    attributes[:channel] = 'jenkins' if attributes[:ci_url]
    attributes[:devices] = param_devices
    attributes[:extra] = JSON.dump(param_extra)

    attributes
  end

  def param_devices
    @devices = nil
    @devices = if params[:devices] && !params[:devices].blank?
                 JSON.dump(params[:devices])
               elsif (extra = JSON.dump(param_extra)) && !extra['devices'].blank?
                 extra['devices']
               else
                 nil
               end
  rescue
    @device = nil
  end

  def param_extra
    return @extra if @extra

    extra = params.clone.to_unsafe_h
    extra.delete(:file)
    extra.delete(:icon) if extra.key?(:icon)

    @extra ||= extra
  end

  def app_params
    params.permit(:identifier, :name, :slug, :device_type, :jenkins_job, :git_url)
  end
end
