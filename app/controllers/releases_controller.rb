class ReleasesController < ApplicationController
  # before_action :authenticate_user!, except: [:show, :auth]
  # before_action :set_app, only: [:show]
  before_action :set_channel, only: [:new, :create]

  ##
  # 查看应用详情
  # GET /channels/:channel_id/releases/:id
  def show
    @title = @release.app_name
  end

  ##
  # 上传应用页面
  # GET /channels/:channel_id/releasess/upload
  def new
    @title = '上传应用'
    @release = @channel.releases.new
  end

  ##
  # 创建新应用
  # POST /channels/:channel_id/releases/create
  def create
    controller = Api::V2::Apps::UploadController.new
    controller.request = request
    controller.response = response
    response = controller.create

    # redirect_to channel_release_path(), notice: '应用已经创建成功！'
  end

  # ##
  # # 编辑应用页面
  # # GET /apps/:slug/edit
  # def edit
  #   @title = '编辑应用'
  #   rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
  # end

  # ##
  # # 更新应用
  # # PUT /apps/:slug/update
  # def update
  #   rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
  #   @app.update(app_params)

  #   redirect_to apps_path
  # end

  # ##
  # # 清除应用及所属所有发型版本和上传的二进制文件
  # # DELETE /apps/:slug/destroy
  # def destroy
  #   @app.destroy

  #   require 'fileutils'
  #   app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
  #   logger.debug "Delete app all binary and icons in #{app_binary_path}"
  #   FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)

  #   redirect_to apps_path
  # end

  # ##
  # # 创建新的构建
  # def build
  # end

  protected

  def set_app
    @release = Release.find(params[:id])
    @app = @release.channel.scheme.app
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end

  # def fetch_apps
  #   @apps = App.all
  # end

  # def app_info
  #   @release =
  #     if params[:version]
  #       @app.releases.find_by(app: @app, version: params[:version])
  #     else
  #       @app.releases.last
  #     end

  #   raise ActiveRecord::RecordNotFound, "Not found release = #{params[:version]}" unless @release
  # end

  # def app_params
  #   @app_params ||= params.require(:app)
  #                         .permit(
  #                           :user_id, :name, :channel,
  #                           schemes_attributes: { name: [] }
  #                         )
  # end
end
