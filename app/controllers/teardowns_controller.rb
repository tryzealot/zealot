# frozen_string_literal: true

class TeardownsController < ApplicationController
  # GET /teardowns/
  def show
  end

  # GET /teardowns/upload
  def new
    @title = '应用解析'
  end

  # POST /teardowns
  def create
    file = params[:file]
    @app_info = AppInfo.parse(file.tempfile)
  rescue AppInfo::UnkownFileTypeError
    flash.now[:message] = '无法识别上传的应用类型'
    render :new
  end
end
