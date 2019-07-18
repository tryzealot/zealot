class WebHooksController < ApplicationController
  before_action :set_app

  # GET /apps/:slug/web_hooks
  def index
    @web_hooks = @app.web_hooks
    @web_hook = WebHook.new
  end

  # POST /apps/:slug/web_hooks
  def create
    @web_hook = WebHook.new(web_hook_params)

    if @web_hook.save
      redirect_to web_hooks_url, notice: '网络钩子创建成功'
    else
      :index
    end
  end

  # DELETE /apps/:slug/web_hooks/1
  def destroy
    @web_hook = WebHook.find(params[:hook_id])
    @web_hook.destroy
    redirect_to web_hooks_url, notice: '网络钩子已经成功删除'
  end

  # POST /apps/:slug/web_hooks/1/test
  def test
    web_hook = WebHook.find(params[:hook_id])
    AppWebHookJob.perform_later 'upload_events', web_hook
    render json: web_hook
  end

  private

  def set_app
    @app =
      if params[:slug]
        App.friendly.find(params[:slug])
      else
        App.find(params[:id])
      end
  end

  def web_hook_params
    params.require(:web_hook).permit(:app_id, :url, :upload_events, :changelog_events)
  end
end
