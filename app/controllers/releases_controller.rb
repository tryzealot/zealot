# frozen_string_literal: true

class ReleasesController < ApplicationController
  before_action :authenticate_login!, except: %i[show auth]
  before_action :set_channel
  before_action :set_release, only: %i[show auth destroy]
  before_action :authenticate_app!, only: :show

  def index
    return redirect_to root_path, notice: "应用不存在或已经被移除，页面跳转至首页" unless @channel
    return redirect_to channel_path(@channel), notice: "应用版本不存在或已经被移除，页面跳转至应用渠道详情" if @channel.releases.empty?
    redirect_to channel_release_path(@channel, @channel.releases.last), notice: "版本不存在或已经被移除，跳转至最新版本"
  end

  def show
    @title = @release.app_name
  end

  def new
    @title = '上传应用'
    @release = @channel.releases.new
    authorize @release
  end

  def create
    @title = '上传应用'
    @release = @channel.releases.upload_file(release_params)
    authorize @release

    return render :new unless @release.save

    # 触发异步任务
    @release.channel.perform_web_hook('upload_events')
    TeardownJob.perform_later(@release.id, current_user&.id)

    redirect_to channel_release_url(@channel, @release), notice: '应用上传成功'
  end

  def destroy
    @release.destroy
    redirect_to channel_versions_url(@channel), notice: '应用版本删除成功'
  end

  def auth
    if @channel.password == params[:password]
      cookies[app_release_auth_key(@release)] = @channel.encode_password
      redirect_to channel_release_path(@channel, @release)
    else
      flash[:danger] = '密码错误，请重新输入'
      render :show
    end
  end

  protected

  def authenticate_login!
    authenticate_user! unless wechat? || Setting.guest_mode
  end

  def authenticate_app!
    return if wechat? || @channel.password.present? || user_signed_in? || Setting.guest_mode
  end

  def wechat?
    request.user_agent.include? 'MicroMessenger'
  end

  def set_release
    @release = Release.find params[:id]
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id]
  end

  def release_params
    params.require(:release).permit(
      :file, :changelog, :release_type, :branch, :git_commit, :ci_url
    )
  end

  def render_not_found_entity_response(e)
    @title = "#{@channel.app_name} 找不到 #{e.id} 版本"
    @release_id = params[:id]
    render :not_found, status: :not_found
  end
end
