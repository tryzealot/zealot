class Channels::VersionsController < ApplicationController
  before_action :set_channel

  def show
    version = params[:id]
    @title = "#{@channel.app_name} - #{version} 版本列表"

    @back_url = URI(request.referer || '').path
    @releases = @channel.releases
                        .where(release_version: version)
                        .order(id: :desc)
  end

  private

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end
end
