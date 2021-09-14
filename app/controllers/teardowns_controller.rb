# frozen_string_literal: true

class TeardownsController < ApplicationController
  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_metadata, only: %i[show destroy]

  def index
    @title = '应用解包'
    @metadata = Metadatum.page(params.fetch(:page, 1))
                         .per(params.fetch(:per_page, 10))
                         .order(id: :desc)
  end

  def show
    @title = "#{@metadata.name} #{@metadata.release_version} (#{@metadata.build_version}) 解包信息"
  end

  def new
    @title = '应用解包'
  end

  def create
    parse_app
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "无法找到解包文件: #{e}"
    render :new
  rescue ActionController::RoutingError => e
    flash[:error] = e.message
    render :new
  rescue AppInfo::UnkownFileTypeError
    flash[:error] = '无法识别上传的应用类型'
    render :new
  rescue AppInfo::NotFoundError => e
    flash[:error] = "无法找到解包文件: #{e}"
    render :new
  rescue AppInfo::UnkownFileTypeError
    flash[:error] = '上传应用的文件类型不支持'
    render :new
  rescue NoMethodError => e
    logger.error "Teardown error: #{e}"
    Sentry.capture_exception e
    flash[:error] = '上传应用解析异常，请确保应用是支持的文件类型且没有安全加固处理'
    render :new
  rescue => e
    logger.error "Teardown error: #{e}"
    Sentry.capture_exception e
    flash[:error] = "上传应用解析发现未知异常，原始错误 [#{e.class}]：#{e.message}"
    render :new
  end

  def destroy
    @metadata.destroy

    redirect_to teardowns_path, notice: "[#{@metadata.id}] #{@metadata.name} 应用解包记录删除成功！"
  end

  private

  def set_metadata
    @metadata = Metadatum.find(params[:id])
    authorize @metadata
  end

  def parse_app
    unless file = params[:file]
      raise ActionController::RoutingError, '请选择需要解包的 ipa、apk 安装包或 .mobileprovision 文件'
    end

    metadata = TeardownService.call(file)
    metadata.update_attribute(:user_id, current_user.id) if current_user.present?

    redirect_to teardown_path(metadata)
  end
end
