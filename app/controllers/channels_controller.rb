# frozen_string_literal: true

class ChannelsController < ApplicationController
  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_channel, only: %i[show edit update destroy]
  before_action :set_scheme, except: %i[show]

  def show
    authorize @channel
    @web_hook = @channel.web_hooks.new
    @releases = @channel.releases
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, Setting.per_page))
                        .order(id: :desc)
    @versions = @channel.release_versions(5)
  end

  def new
    @title = t('channels.new.title', name: @scheme.app_name)
    @channel = Channel.new
    authorize @channel
  end

  def create
    @channel = Channel.new(channel_params)
    authorize @channel

    app_url = app_path(@channel.scheme.app)
    return redirect_to app_url, alert: @channel.errors.full_messages.to_sentence unless @channel.save

    message = t('activerecord.success.create', key: "#{@channel.scheme.name} #{@channel.name} #{t('channels.title')}")
    redirect_to app_url, notice: message
  end

  def edit
    authorize @channel

    @title = t('channels.edit.title', name: @scheme.app_name)
  end

  def update
    authorize @channel

    @channel.update(channel_params)
    redirect_to (referer_url || friendly_channel_overview_path(@channel))
  end

  def destroy
    @channel.destroy

    redirect_to app_path(@app), status: :see_other
  end

  protected

  def set_scheme
    @scheme = Scheme.find(params[:scheme_id])
  end

  def set_channel
    @channel = Channel.friendly.find(params[:id] || params[:channel])
    @app = @channel.scheme.app
    @title = @channel.app_name
    @subtitle = t('channels.subtitle', total_scheme: @app.schemes.count, total_channel: @channel.scheme.channels.count)
  end

  def referer_url
    @referer_url ||= params[:referer_url]
  end

  def channel_params
    params.require(:channel).permit(
      :scheme_id, :name, :device_type, :bundle_id,
      :slug, :password, :git_url
    )
  end

  def render_not_found_entity_response(e)
    redirect_to apps_path, notice: t('channels.messages.errors.not_found_channel', id: e.id)
  end
end
