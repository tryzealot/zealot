# frozen_string_literal: true

class Channels::VersionsController < ApplicationController
  before_action :set_channel
  before_action :set_version, except: %i[ index ]

  def index
    authorize @channel, :versions?

    @title = @channel.app_name
    @subtitle = t('.subtitle')
    @releases = @channel.releases
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))

    render 'channels/filters/index'
  end

  def show
    authorize @channel, :versions?

    @title = @channel.app_name
    @subtitle = t('.subtitle', version: @version)
    @back_url = URI(request.referer || '').path
    @releases = @channel.releases
                        .where(release_version: @version)
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))

    render 'channels/filters/index'
  end

  def destroy
    authorize @channel, :destroy_releases?
    @channel.releases.where(release_version: @version).destroy_all

    redirect_to friendly_channel_versions_path(@channel), status: :see_other
  end

  private

  def set_channel
    @channel = Channel.friendly.find(params[:channel_id] || params[:channel])
  end

  def set_version
    @version = params[:id] || params[:name]
  end
end
