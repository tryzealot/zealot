# frozen_string_literal: true

class ChannelsController < ApplicationController
  include AppArchived

  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_scheme, except: %i[show destroy_releases]
  before_action :set_channel, only: %i[show edit update destroy]

  def show
    @web_hook = @channel.web_hooks.new
    @releases = @channel.releases
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))
                        .order(id: :desc)
    @versions = @channel.release_versions(5)
  end

  def new
    raise_if_app_archived!(@scheme.app)

    @channel = @scheme.channels.build
    @page_title = t('.title.with_name', app: @channel.app.name)
    @title = t('.title.without_name')
    authorize @channel
  end

  def create
    raise_if_app_archived!(@scheme.app)

    @channel = @scheme.channels.new(channel_params)
    authorize @channel

    app_url = app_path(@channel.scheme.app)
    return redirect_to app_url, alert: @channel.errors.full_messages.to_sentence unless @channel.save

    notice = t('activerecord.success.create', key: "#{@channel.scheme.name} #{@channel.name} #{t('channels.title')}")
    flash[:notice] = notice
    respond_to do |format|
      format.html { redirect_to app_url }
      format.turbo_stream
    end
  end

  def edit
    raise_if_app_archived!(@scheme.app)

    @page_title = t('.title.with_name', app: @channel.app.name)
    @title = t('.title.without_name')
  end

  def update
    raise_if_app_archived!(@scheme.app)

    @channel.update(channel_params)
    notice = t('activerecord.success.update', key: "#{@channel.scheme.name} #{@channel.name} #{t('channels.title')}")
    flash[:notice] = notice
    respond_to do |format|
      format.html { redirect_back fallback_location: friendly_channel_overview_path(@channel) }
      format.turbo_stream
    end
  end

  def destroy
    raise_if_app_archived!(@scheme.app)

    @channel.destroy
    notice = t('activerecord.success.destroy', key: "#{@channel.scheme.name} #{@channel.name} #{t('channels.title')}")
    flash[:notice] = notice
    respond_to do |format|
      format.html { redirect_to app_path(@app) }
      format.turbo_stream
    end
  end

  def destroy_releases
    channel = Channel.friendly.find(params[:name] || params[:id])
    authorize channel

    raise_if_app_archived!(channel.app)

    if params[:channel].blank?
      channel.releases.destroy_all
    else
      delete_params = params.require(:channel).permit(release_ids: [])
      channel.releases.where(id: delete_params[:release_ids]).destroy_all
    end

    redirect_back fallback_location: friendly_channel_versions_path(channel), status: :see_other
  end

  protected

  def set_scheme
    @scheme = Scheme.find(params[:scheme_id])
  end

  def set_channel
    @channel = Channel.friendly.find(params[:id] || params[:channel])
    authorize @channel

    @app = @channel.scheme.app
    @title = @channel.app_name
    @subtitle = t('channels.subtitle', total_scheme: @app.schemes.count, total_channel: @channel.scheme.channels.count)
  end

  def channel_params
    params.require(:channel).permit(
      :scheme_id, :name, :device_type, :bundle_id,
      :slug, :password, :git_url, :download_filename_type
    )
  end

  def render_not_found_entity_response(e)
    redirect_to apps_path, notice: t('channels.messages.errors.not_found_channel', id: e.id)
  end
end
