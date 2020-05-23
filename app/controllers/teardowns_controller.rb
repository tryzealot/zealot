# frozen_string_literal: true

class TeardownsController < ApplicationController

  def index
    redirect_to new_teardown_path, alert: "链接失效，请重新解析文件"
  end

  def show
  end

  def new
    @title = '应用解析'
  end

  def create
    if params[:file]
      parse_file
    else
      parse_exists_app
    end

  rescue AppInfo::UnkownFileTypeError
    flash[:error] = '无法识别上传的应用类型'
    render :new
  rescue AppInfo::NotFoundError => e
    flash[:error] = "无法找到安装包: #{e}"
    render :new
  end

  private

  def parse_file
    file = params[:file]
    @app_info = AppInfo.parse(file.tempfile)
  end

  def parse_exists_app
    data = Rails.application.routes.recognize_path(params[:url])
    unless data[:controller] == 'releases' && data[:action] == 'show'
      raise ActionController::RoutingError, '链接不匹配'
    end

    release = Release.find(data[:id])
    @app_info = AppInfo.parse(release.file.file.path)
  end
end
