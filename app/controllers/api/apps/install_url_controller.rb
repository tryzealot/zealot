# frozen_string_literal: true

# 依赖 view 只能继承 ApplicationController
class Api::Apps::InstallUrlController < ApplicationController
  # GET /api/apps/install
  def show
    @release = Release.version_by_channel(params[:slug], params[:version])
    if @release
      render content_type: 'text/xml', layout: false
    else
      render json: { error: '没有找到对应的应用或版本' }, status: :not_found
    end
  end
end
