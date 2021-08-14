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
    case params[:type]
    when 'upload'
      parse_app
    when 'url'
      parse_exists_app
    else
      flash[:error] = '错误请求，无法解包'
      render :new
    end
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

    parse(file.tempfile)
  end

  def parse_exists_app
    data = Rails.application.routes.recognize_path(params[:url])
    determine_release_detail_url!(data)
    find_release_and_parse(data[:id])
  end

  def parse(file, release_id = nil)
    metadata = TeardownService.call(file)
    metadata.update_attribute(:release_id, release_id) if release_id.present?
    metadata.update_attribute(:user_id, current_user.id) if current_user.present?

    redirect_to teardown_path(metadata)
  end

  def determine_release_detail_url!(data)
    unless data[:controller] == 'releases' && data[:action] == 'show'
      raise ActionController::RoutingError, '不是正确的版本详情链接，请重试'
    end
  end

  def find_release_and_parse(release_id)
    release = Release.find(release_id)
    unless release&.file.file && File.exist?(release.file.file.path)
      raise ActionController::RoutingError, '文件已经无法找到，可能已经被清理或删除，请重试'
    end

    parse(release.file.file.path, release_id)
  end
end
