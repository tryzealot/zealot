class WebHooksController < ApplicationController
  before_action :set_app, only: [:index, :create, :test, :destroy]

  # GET /apps/:slug/web_hooks
  # GET /web_hooks.json
  def index
    @web_hooks = @app.web_hooks
    @web_hook = WebHook.new
  end

  # POST /web_hooks/1/test
  def test
    web_hook = WebHook.find(params[:hook_id])
    AppWebHookJob.perform_later 'upload_events', web_hook
    render json: web_hook
  end

  # POST /web_hooks
  # POST /web_hooks.json
  def create
    @web_hook = WebHook.new(web_hook_params)

    respond_to do |format|
      if @web_hook.save
        format.html { redirect_to web_hooks_path(@app), notice: 'Web hook was successfully created.' }
        format.json { render :show, status: :created, location: @web_hook }
      else
        format.html { render :new }
        format.json { render json: @web_hook.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /web_hooks/1
  # DELETE /web_hooks/1.json
  def destroy
    @web_hook.destroy
    respond_to do |format|
      format.html { redirect_to web_hooks_url, notice: 'Web hook was successfully destroyed.' }
      format.json { head :no_content }
    end
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
