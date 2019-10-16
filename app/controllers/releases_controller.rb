# frozen_string_literal: true

require 'app-info'

class ReleasesController < ApplicationController
  include AppsHelper

  before_action :check_user_logged_in, except: [:show, :auth]
  before_action :set_channel
  before_action :set_release, only: [:show, :auth]

  def show
    redirect_to new_user_session_path unless !wechat? || @channel.password.blank? || !user_signed_in?

    @title = @release.app_name
  end

  def new
    @title = '上传应用'
    @release = @channel.releases.new
  end

  def create
    @release = @channel.releases.upload_file(release_params)
    return render :new unless @release.save

    redirect_to channel_release_url(@channel, @release), notice: '应用上传成功'
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

  def release_params
    params.require(:release).permit(
      :file, :changelog, :release_type, :branch, :git_commit, :ci_url
    )
  end
end
