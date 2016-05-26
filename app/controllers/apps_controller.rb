class AppsController < ApplicationController
  before_filter :check_user_logged_in, except: [:show, :auth, :qrcode]
  before_action :set_app, except: [:index, :create, :new]
  ##
  # App 列表
  # GET /apps
  def index
    @title = '应用管理'
    @apps = current_user.apps
  end

  # GET /apps/new
  def new
    @title = "新建应用"
    @app = App.new
  end

  def create
    @app = App.new(app_params)

    respond_to do |format|
      if @app.save
        format.html { redirect_to apps_path, notice: 'App was successfully created.' }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @title = '编辑应用'
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
  end

  def update
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
    @app.update(app_params)

    redirect_to apps_path
  end

  def destroy
    @app.destroy
    redirect_to apps_path
  end

  def show
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app

    if wechat? || !@app.password.blank? || user_signed_in?
      app_info
    else
      redirect_to new_user_session_path
    end
  end

  def auth
    if @app.password == params[:password]
      cookies[:auth] = { value: Digest::MD5.hexdigest(@app.password), expires: Time.now + 1.week }
      redirect_to app_path(@app.slug)
    else
      flash[:danger] = '密码错误，请重新输入'
      render :show
    end
  end

  def release
    @release = Release.find_by(app: @app, version: params[:version])
    render 'apps/show'
  end

  def upload
  end

  def build
  end

  def branches
    @branches = @app.branches
    @releases = @app.releases.where(branch: params[:branch]).order(created_at: :desc) if params[:branch]
  end

  def versions
    @releases = @app.releases.where(release_version: params[:version])
  end

  def web_hooks
    @web_hook = WebHook.new
  end

  def qrcode
    url =
      if params[:version]
        @release = @app.releases.last
        url_for(
          host: Rails.application.secrets.domain_name,
          controller: 'apps',
          action: 'release',
          slug: @app.slug,
          version: @release.version
        )
      else
        url_for(
          host: Rails.application.secrets.domain_name,
          controller: 'apps',
          action: 'show',
          slug: @app.slug
        )
      end

    render qrcode: url, module_px_size: 3, fill: '#F4F5F6', color: '#465960'
  end

  private

  def set_app
    @app =
      if params[:slug]
        App.friendly.find(params[:slug])
      else
        App.find(params[:id])
      end
  end

  def app_info
    @release = @app.releases.last
    client = JenkinsApi::Client.new(
      server_ip: '172.1.1.227',
      server_port: '8888'
    )

    unless @app.jenkins_job.to_s.empty?
      @job = client.job.list_details(@app.jenkins_job)
      current_status = client.job.get_current_build_status(@app.jenkins_job)
      @job['status'] = current_status
    end
  end

  def check_user_logged_in
    authenticate_user! unless wechat?
  end

  def wechat?
    request.user_agent.include? 'MicroMessenger'
  end

  def app_params
    params.require(:app).permit(
      :user_id, :name, :device_type, :identifier, :slug, :password,
      :jenkins_job, :git_url, :git_branch
    )
  end
end
