# frozen_string_literal: true

class Releases::InstallController < ApplicationController
  def show
    @release = Release.version_by_channel(params[:channel_id], params[:release_id])
    render content_type: 'text/xml', layout: false
  end

  private

  def render_not_found_entity_response
    render json: { error: '没有找到对应的应用或版本' }, status: :not_found
  end
end

