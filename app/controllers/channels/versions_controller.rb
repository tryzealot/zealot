# frozen_string_literal: true

class Channels::VersionsController < ApplicationController
  before_action :set_channel
  before_action :set_version

  def index
    @title = @channel.app_name
    @subtitle = t('.subtitle')
    @releases = @channel.releases
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))

    render 'channels/filters/index'
  end

  def show
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

  private

  def set_channel
    @channel = Channel.friendly.find(params[:channel_id] || params[:channel])
    authorize @channel, :versions?
  end

  def set_version
    @version = params[:id] || params[:name]
  end
end
