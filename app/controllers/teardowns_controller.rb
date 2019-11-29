# frozen_string_literal: true

require 'app-info'

class TeardownsController < ApplicationController
  # GET /teardowns/
  def show
  end

  # GET /teardowns/upload
  def new
    @title = 'App 解析'
  end

  # POST /teardowns
  def create
    file = params[:file]
    @app_info = AppInfo.parse(file.tempfile)
  end
end
