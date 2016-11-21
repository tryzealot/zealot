class AppsController < ApplicationController
  before_filter :check_user_logged_in, except: [:show, :auth]
  before_action :set_app, except: [:index, :create, :new]

  ##
  # App 列表
  # GET /apps
  def index
    @title = '应用管理'
    @apps = current_user.apps
  end

  ##
  # 查看应用详情
  # GET /apps/:slug
  def show
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app

    if wechat? || !@app.password.blank? || user_signed_in?
      app_info
    else
      redirect_to new_user_session_path
    end
  end

  ##
  # 新应用页面
  # GET /apps/new
  def new
    @title = "新建应用"
    @app = App.new
  end

  ##
  # 创建新应用
  # POST /apps/create
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

  ##
  # 编辑应用页面
  # GET /apps/:slug/edit
  def edit
    @title = '编辑应用'
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
  end

  ##
  # 更新应用
  # PUT /apps/:slug/update
  def update
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
    @app.update(app_params)

    redirect_to apps_path
  end

  ##
  # 清除应用及所属所有发型版本和上传的二进制文件
  # DELETE /apps/:slug/destroy
  def destroy
    @app.destroy
    @app.releases.destroy_all

    require 'fileutils'
    app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
    logger.debug "Delete app all binary and icons in #{app_binary_path}"
    FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)

    redirect_to apps_path
  end

  ##
  # 应用密码认证
  # GET /apps/auth
  def auth
    if @app.password == params[:password]
      cookies[:auth] = { value: Digest::MD5.hexdigest(@app.password), expires: Time.now + 1.week }
      redirect_to app_path(@app.slug)
    else
      flash[:danger] = '密码错误，请重新输入'
      render :show
    end
  end

  ##
  # 上传新版本页面
  def upload
  end

  ##
  # 创建新的构建
  def build
  end

  protected

  def set_app
    @app =
      if params[:slug]
        App.friendly.find(params[:slug])
      else
        App.find(params[:id])
      end
  end

  def app_info
    @release = if params[:version]
      @app.releases.find_by(app: @app, version: params[:version])
    else
      @app.releases.last
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
