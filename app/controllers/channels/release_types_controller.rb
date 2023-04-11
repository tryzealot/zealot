# frozen_string_literal: true

class Channels::ReleaseTypesController < ApplicationController
  before_action :set_channel
  before_action :set_releases

  def index
    @title = @channel.app_name
    @subtitle = t('.subtitle', type: @type)

    render 'channels/filters/index'
  end

  private

  def set_releases
    @type = params[:name]
    @releases = @channel.releases
                        .where(release_type: @type)
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))
  end

  def set_channel
    @channel = Channel.friendly.find(params[:channel_id] || params[:channel])
    authorize @channel, :release_types?
  end
end
