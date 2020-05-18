# frozen_string_literal: true

class Releases::InstallController < ApplicationController
  def show
    @release = Release.version_by_channel(params[:channel_id], params[:id])

    if @release
      render content_type: 'text/xml', layout: false
    else
      render json: { error: '没有找到对应的应用或版本' }, status: :not_found
    end
  end
end

