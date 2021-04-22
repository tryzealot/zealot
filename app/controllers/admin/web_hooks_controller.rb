# frozen_string_literal: true

class Admin::WebHooksController < ApplicationController
  before_action :set_web_hook, only: %i[show edit update destroy]

  def index
    @title = t('menu.web_hooks')
    @web_hooks = WebHook.all
    authorize @web_hooks
  end

  def show
    @title = '网络钩子详情'
  end

  def new
    @title = '新建网络钩子'
    @web_hook = WebHook.new
    authorize @web_hook
  end

  def create
    @web_hook = WebHook.new(web_hook_params)
    authorize @web_hook
    return render :new unless @web_hook.save

    redirect_to admin_users_url, notice: '网络钩子创建成功'
  end

  def edit
    @title = '编辑网络钩子'
  end

  def update
    return render :edit unless @web_hook.update(web_hook_params)

    redirect_to admin_web_hooks_url, notice: '网络钩子已经更新'
  end

  def destroy
    @web_hook.destroy
    redirect_to admin_web_hooks_url, notice: '网络钩子已经删除'
  end

  private

  def set_web_hook
    @web_hook = WebHook.find(params[:id])
    authorize @web_hook
  end

  def web_hook_params
    params.require(:web_hook).permit(:url, :upload_events, :download_events, :changelog_events)
  end
end
