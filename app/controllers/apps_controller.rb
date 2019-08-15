class AppsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :auth]
  before_action :set_app, except: [:index, :create, :new, :upload]
  before_action :fetch_apps, only: [:index]

  ##
  # App 列表
  # GET /apps
  def index
    @title = '应用管理'
  end

  ##
  # 查看应用详情
  # GET /apps/:slug
  def show
    @title = @app.name
  end

  ##
  # 新应用页面
  # GET /apps/new
  def new
    @title = '新建应用'
    @app = App.new
    @app.schemes.build
  end

  ##
  # 创建新应用
  # POST /apps/create
  def create
    schemes = app_params.delete(:schemes_attributes)
    channel = app_params.delete(:channel)

    # return render json: channels
    @app = App.new(app_params)
    return render :new unless @app.save

    create_schemes_by(@app, schemes, channel)
    redirect_to apps_path, notice: '应用已经创建成功！'
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

    require 'fileutils'
    app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
    logger.debug "Delete app all binary and icons in #{app_binary_path}"
    FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)

    redirect_to apps_path
  end

  # ##
  # # 创建新的构建
  # def build
  # end

  protected

  def create_schemes_by(app, schemes, channel)
    schemes.values[0][:name].each do |scheme_name|
      next if scheme_name.empty?

      scheme = app.schemes.create name: scheme_name
      next unless channels = channel_value(channel)

      channels.each do |channel_name|
        scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
      end
    end
  end

  def channel_value(platform)
    case platform
    when 'ios' then ['iOS']
    when 'android' then ['Android']
    when 'both' then ['Android', 'iOS']
    end
  end

  def set_app
    @app = App.find(params[:id])
  end

  def fetch_apps
    @apps = App.all
  end

  def app_info
    @release =
      if params[:version]
        @app.releases.find_by(app: @app, version: params[:version])
      else
        @app.releases.last
      end

    raise ActiveRecord::RecordNotFound, "Not found release = #{params[:version]}" unless @release
  end

  def app_params
    @app_params ||= params.require(:app)
                          .permit(
                            :user_id, :name, :channel,
                            schemes_attributes: { name: [] }
                          )
  end
end
