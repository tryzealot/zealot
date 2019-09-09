class ReleasesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :auth]
  before_action :set_channel, only: [:new, :create]
  before_action :set_release, only: [:show]

  def show
    @title = @release.app_name
  end

  def new
    @title = '上传应用'
    @release = @channel.releases.new
  end

  protected

  def set_release
    @release = Release.find(params[:id])
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end
end
