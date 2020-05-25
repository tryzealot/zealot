# frozen_string_literal: true

class TeardownsController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to new_teardown_path, alert: "链接失效，请重新解析文件"
  end

  def show
  end

  def new
    @title = '应用解析'
  end

  def create
    # return render json: params
    case params[:type]
    when 'upload'
      parse_file
    when 'url'
      parse_exists_app
    else
      flash[:error] = '错误请求，无法解析'
      render :new
    end
  rescue ActionController::RoutingError => e
    flash[:error] = e.message
    render :new
  rescue AppInfo::UnkownFileTypeError
    flash[:error] = '无法识别上传的应用类型'
    render :new
  rescue AppInfo::NotFoundError => e
    flash[:error] = "无法找到安装包: #{e}"
    render :new
  end

  private

  def parse_file
    unless file = params[:file]
      raise ActionController::RoutingError, '请选择需要解析的 ipa 或 apk 安装包'
    end

    @app_info = AppInfo.parse(file.tempfile)
  end

  def parse_exists_app
    data = Rails.application.routes.recognize_path(params[:url])
    unless data[:controller] == 'releases' && data[:action] == 'show'
      raise ActionController::RoutingError, '不是正确的版本详情链接，请重试'
    end

    release = Release.find(data[:id])
    @app_info = AppInfo.parse(release.file.file.path)
  end
end
