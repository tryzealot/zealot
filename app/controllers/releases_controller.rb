class ReleasesController < ApplicationController
  include AppsHelper

  before_action :check_user_logged_in, except: [:show, :auth]
  before_action :set_channel
  before_action :set_release, only: [:show, :auth]

  def show
    redirect_to new_user_session_path unless !wechat? || @channel.password.blank? || !user_signed_in?
    # redirect_to auth_channel_release_path(@channel, @release) unless @channel.password.blank?

    @title = @release.app_name
  end

  def new
    @title = '上传应用'
    @release = @channel.releases.new
  end

  def auth
    if @channel.password == params[:password]
      cookies[app_release_auth_key(@release)] = encode_password(@channel)
      redirect_to channel_release_path(@channel, @release)
    else
      flash[:danger] = '密码错误，请重新输入'
      render :show
    end
  end

  protected

  def set_release
    @release = Release.find(params[:id])
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end

  def check_user_logged_in
    authenticate_user! unless wechat?
  end

  def wechat?
    request.user_agent.include? 'MicroMessenger'
  end
end
