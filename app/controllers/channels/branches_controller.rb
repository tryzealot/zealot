# frozen_string_literal: true

class Channels::BranchesController < ApplicationController
  before_action :set_channel
  before_action :set_releases

  def index
    @title = @channel.app_name
    @subtitle = t('.subtitle', branch: @branch)
    render 'channels/filters/index'
  end

  private

  def set_releases
    @branch = params[:name]
    @releases = @channel.releases
                        .where(branch: @branch)
                        .order(id: :desc)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))
  end

  def set_channel
    @channel = Channel.friendly.find(params[:channel_id] || params[:channel])
    authorize @channel, :branches?
  end
end
