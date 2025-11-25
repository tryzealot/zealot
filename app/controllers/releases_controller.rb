# frozen_string_literal: true

class ReleasesController < ApplicationController
  include AppArchived

  before_action :authenticate_login!, except: %i[index show auth]
  before_action :set_channel
  before_action :set_release, only: %i[show auth destroy]
  before_action :authenticate_app!, only: :show

  def index
    if @channel.releases.empty?
      return redirect_to friendly_channel_overview_path(@channel),
        notice: t('releases.messages.errors.not_found_release_and_redirect_to_channel')
    end

    @release = @channel.releases.last
    authorize @release, :show?

    @title = @release.app_name
    render :show
  end

  def show
    authorize @release

    unless @release.custom_fields.is_a?(Array)
      flash.now[:warn] = t('.custom_fields_invalid_json_format')
    end
  end

  def new
    raise_if_app_archived!(@channel.app)

    @title = t('releases.new.title')
    @release = @channel.releases.new
    authorize @release
  end

  def create
    raise_if_app_archived!(@channel.app)

    if @channel.app.archived == true
      message = t('releases.messages.errors.upload_to_archived_app', app: @channel.app.name)
      redirect_to channel_path(@channel), alert: message
      return
    end

    @title = t('releases.new.title')
    @release = @channel.releases.upload_file(release_params)
    authorize @release

    return render :new, status: :unprocessable_entity unless @release.save

    # Trigger webhooks and teardown jobs
    @release.channel.perform_web_hook('upload_events', current_user.id)
    @release.perform_teardown_job(current_user.id)

    message = t('activerecord.success.create', key: "#{t('releases.title')}")
    redirect_to channel_release_path(@channel, @release), notice: message
  end

  def destroy
    authorize @release
    raise_if_app_archived!(@channel.app)

    @release.destroy

    notice = t('activerecord.success.destroy', key: "#{t('releases.title')}")
    redirect_to friendly_channel_releases_path(@channel), status: :see_other, notice: notice
  end

  def auth
    raise_if_app_archived!(@channel.app)

    unless @release.password_match?(cookies, params[:password])
      @error_message = t('releases.messages.errors.invalid_password')
      return render :show, status: :unprocessable_entity
    end

    back_url = params[:back_url] || friendly_channel_release_path(@channel, @release)
    redirect_to back_url, status: :see_other
  end

  protected

  def authenticate_login!
    authenticate_user! unless app_limited? || Setting.guest_mode
  end

  def authenticate_app!
    return if app_limited? || @channel.password.present? || user_signed_in? || Setting.guest_mode
  end

  def app_limited?
    Setting.preset_install_limited
      .find {|q| request.user_agent&.include?(q) }
      .present?
  end

  def set_release
    @release = @channel.releases.find params[:id]
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id] || params[:channel]
  end

  def release_params
    params.require(:release).permit(
      :file, :changelog, :release_version, :build_version, :release_type, :branch, :git_commit, :ci_url
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
        unless user_signed_in_or_guest_mode?
          @link_title = @link_href = nil
        end
      when 'Release'
        @title = t('releases.messages.errors.not_found_release')
        if (current_user || Setting.guest_mode)
          @link_title = t('releases.messages.errors.reidrect_channel_detal')
          @link_href = friendly_channel_overview_path(@channel)
        else
          @link_title = t('releases.messages.errors.not_found_release_and_redirect_to_latest_release')
          @link_href = friendly_channel_releases_path(@channel)
        end

      end
    end

    render 'releases/not_found', status: :not_found
  end
end
