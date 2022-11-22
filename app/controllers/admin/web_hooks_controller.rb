# frozen_string_literal: true

class Admin::WebHooksController < ApplicationController
  before_action :set_web_hook, only: %i[edit update destroy]

  def index
    @web_hooks = WebHook.all
    authorize @web_hooks
  end

  def edit
    authorize @web_hook
  end

  def update
    authorize @web_hook
    channel_ids = web_hook_params.delete(:channel_ids)
    return render :edit, status: :unprocessable_entity unless @web_hook.update(web_hook_params)

    redirect_to admin_web_hooks_url, notice: t('activerecord.success.update', key: t('admin.web_hooks.title'))
  end

  def destroy
    authorize @web_hook
    @web_hook.destroy

    notice = t('activerecord.success.destroy', key: t('admin.web_hooks.title'))
    redirect_to admin_web_hooks_url, status: :see_other, notice: notice
  end

  private

  def set_web_hook
    @web_hook = WebHook.find(params[:id])
  end

  def web_hook_params
    params.require(:web_hook).permit(
      :url, :body, :upload_events, :download_events, :changelog_events,
      channel_ids: []
    )
  end
end
