# frozen_string_literal: true

class Channels::ReleaseTypesController < ApplicationController
  before_action :set_channel
  before_action :set_releases

  def index
    @title = @channel.app_name
    @subtitle = "#{@type} 类型版本列表"

    render 'channels/filters/index'
  end

  private

  def set_releases
    @type = params[:name]
    @releases = @channel.releases
                        .where(release_type: @type)
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 10))
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end
end
