# frozen_string_literal: true

class WebHooksController < ApplicationController
  include AppArchived

  before_action :authenticate_user!
  before_action :set_channel
  before_action :set_web_hook, except: [:create]

  def create
    @web_hook = WebHook.new(web_hook_params)
    authorize @web_hook
    unless @web_hook.save
      return redirect_to_channel_url status: :see_other, alert: @web_hook.errors.full_messages.join(', ')
    end

    @channel.web_hooks << @web_hook

    flash.now[:notice] = t('activerecord.success.create', key: t('web_hooks.title'))
    redirect_to_channel_url 
  end

  def destroy
    authorize @web_hook
    @web_hook.destroy

    flash.now[:notice] = t('activerecord.success.destroy', key: t('web_hooks.title'))
    redirect_to_channel_url status: :see_other
  end

  def disable
    authorize @web_hook
    @channel.web_hooks.delete @web_hook

    flash.now[:notice] = t('admin.web_hooks.messages.success.disable')
    redirect_to_channel_url
  end

  def enable
    authorize @web_hook
    @web_hook.channels << @channel

    flash.now[:notice] = t('admin.web_hooks.messages.success.enable')
    redirect_to channel_url(@channel, anchor: 'enabled')
  end

  def test
    authorize @web_hook
    event = params[:event] || 'upload_events'
    AppWebHookJob.perform_later event, @web_hook, @channel, current_user.id

    flash.now[:notice] = t('admin.web_hooks.messages.success.test')
    redirect_to_channel_url
  end

  private

  def set_channel
    @channel = Channel.friendly.find(params[:channel_id])
    raise_if_app_archived!(@channel.app)
  end

  def set_web_hook
    @web_hook = WebHook.find(params[:id])
  end

  def web_hook_params
    params.require(:web_hook).permit(
      :channel_id, :url, :body,
      :upload_events, :changelog_events, :download_events
    )
  end

  def redirect_to_channel_url(**options)
    redirect_to friendly_channel_overview_path(@channel), **options
  end
end
