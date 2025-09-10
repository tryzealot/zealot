# frozen_string_literal: true

class Releases::InstallController < ApplicationController
  before_action :authenticate_user!, only: :authenticate_and_redirect

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response

  def show
    @release = Release.version_by_channel(params[:channel_id], params[:release_id])
    render content_type: 'text/xml', layout: false
  end

  def authenticate_and_redirect
    ios_url = channel_release_install_url(params[:channel_id], params[:release_id])
    url = "itms-services://?action=download-manifest&url=#{ios_url}"

    redirect_to url
  end

  private

  def render_not_found_entity_response
    render xml: { error: t('.not_found') }, status: :not_found
  end
end

