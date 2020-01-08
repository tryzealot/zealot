class Channels::VersionsController < ApplicationController
  before_action :set_channel

  def index
    @title = @channel.app_name
    @releases = @channel.releases
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 10))
  end

  def show
    @version = params[:id]
    @title = @channel.app_name

    @back_url = URI(request.referer || '').path
    @releases = @channel.releases
                        .where(release_version: @version)
                        .order(id: :desc)
  end

  private

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end
end
