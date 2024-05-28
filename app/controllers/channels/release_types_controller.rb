# frozen_string_literal: true

class Channels::ReleaseTypesController < ApplicationController
  before_action :set_channel
  before_action :set_releases

  def index
    authorize @channel, :release_types?

    @title = @channel.app_name
    @subtitle = t('.subtitle', type: @type)

    render 'channels/filters/index'
  end

  def destroy
    authorize @channel, :destroy_releases?

    @channel.releases.where(release_type: @type).destroy_all
    redirect_to friendly_channel_versions_path(@channel), status: :see_other
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
  end
end
