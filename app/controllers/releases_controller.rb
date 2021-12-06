# frozen_string_literal: true

class ReleasesController < ApplicationController
  before_action :authenticate_login!, except: %i[show auth]
  before_action :set_channel
  before_action :set_release, only: %i[show auth destroy]
  before_action :authenticate_app!, only: :show

  def index
    if @channel.releases.empty?
      return redirect_to channel_path(@channel),
        notice: t('releases.messages.errors.not_found_release_and_redirect_to_channel')
    end

    redirect_to channel_release_path(@channel, @channel.releases.last),
      notice: t('releases.messages.errors.not_found_release_and_redirect_to_latest_release')
  end

  def show
    @title = @release.app_name
  end

  def new
    @title = t('releases.new.title')
    @release = @channel.releases.new
    authorize @release
  end

  def create
    @title = t('releases.new.title')
    @release = @channel.releases.upload_file(release_params)
    authorize @release

    return render :new unless @release.save

    # 触发异步任务
    @release.channel.perform_web_hook('upload_events')
    @release.perform_teardown_job(current_user.id)

    message = t('activerecord.success.create', key: "#{t('apps.title')}")
    redirect_to channel_release_url(@channel, @release), notice: message
  end

  def destroy
    @release.destroy
    redirect_to channel_versions_url(@channel), notice: t('activerecord.success.destroy', key: "#{t('apps.title')}")
  end

  def auth
    if @channel.password == params[:password]
      cookies["app_release_#{@release.id}_auth"] = @channel.encode_password
      redirect_to channel_release_path(@channel, @release)
    else
      @error_message = t('releases.messages.errors.invalid_password')
      render :show
    end
  end

  protected

  def authenticate_login!
    authenticate_user! unless app_limited? || Setting.guest_mode
  end

  def authenticate_app!
    return if app_limited? || @channel.password.present? || user_signed_in? || Setting.guest_mode
  end

  def app_limited?
    request.user_agent.include?('MicroMessenger') || request.user_agent.include?('DingTalk')
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

  def not_found(e)
    @e = e
    @title = t('releases.messages.errors.not_found')
    @link_title = t('releases.messages.errors.redirect_to_app_list')
    @link_href = apps_path
    case e
    when ActiveRecord::RecordNotFound
      case e.model
      when 'Channel'
        @title = t('releases.messages.errors.not_found_app')
      when 'Release'
        @title = t('releases.messages.errors.not_found_release')
        @link_title = t('releases.messages.errors.reidrect_channel_detal')
        @link_href = channel_path(@channel)
      end
    end

    render :not_found, status: :not_found
  end
end
