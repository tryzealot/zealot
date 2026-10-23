# frozen_string_literal: true

module Apps
  # App-scoped management of web hooks: one place to create a hook, pick the
  # channels it fires for (that is the "sharing"), edit it and remove it.
  class WebHooksController < ApplicationController
    include AppArchived

    before_action :authenticate_user!
    before_action :set_app
    before_action :set_web_hook, only: %i[edit update destroy test]

    # GET /apps/:app_id/web_hooks
    def index
      @title = t('web_hooks.title')
      load_web_hooks
      authorize @app, :update?
    end

    # GET /apps/:app_id/web_hooks/new
    def new
      @title = t('web_hooks.new.title')
      @web_hook = WebHook.new
      authorize @app, :update?
    end

    # POST /apps/:app_id/web_hooks
    def create
      raise_if_app_archived!(@app)
      authorize @app, :update?

      @web_hook = WebHook.new(web_hook_attributes)
      assign_channels
      unless @web_hook.errors.empty? && @web_hook.save
        @title = t('web_hooks.new.title')
        return render :new, status: :unprocessable_entity
      end

      load_web_hooks
      flash.now[:notice] = t('activerecord.success.create', key: t('web_hooks.title'))
      respond_to do |format|
        format.html { redirect_to app_web_hooks_path(@app) }
        format.turbo_stream
      end
    end

    # GET /apps/:app_id/web_hooks/:id/edit
    def edit
      @title = t('web_hooks.edit.title')
      authorize @app, :update?
    end

    # PATCH/PUT /apps/:app_id/web_hooks/:id
    def update
      raise_if_app_archived!(@app)
      authorize @app, :update?

      @web_hook.assign_attributes(web_hook_attributes)
      assign_channels
      unless @web_hook.errors.empty? && @web_hook.save
        @title = t('web_hooks.edit.title')
        return render :edit, status: :unprocessable_entity
      end

      load_web_hooks
      flash.now[:notice] = t('activerecord.success.update', key: t('web_hooks.title'))
      respond_to do |format|
        format.html { redirect_to app_web_hooks_path(@app) }
        format.turbo_stream
      end
    end

    # DELETE /apps/:app_id/web_hooks/:id
    def destroy
      raise_if_app_archived!(@app)
      authorize @app, :update?

      @web_hook.destroy
      load_web_hooks

      flash.now[:notice] = t('activerecord.success.destroy', key: t('web_hooks.title'))
      respond_to do |format|
        format.html { redirect_to app_web_hooks_path(@app), status: :see_other }
        format.turbo_stream
      end
    end

    # GET /apps/:app_id/web_hooks/:id/test/:event
    def test
      raise_if_app_archived!(@app)
      authorize @app, :update?

      event = params[:event].presence || 'upload_events'
      AppWebHookJob.perform_later event, @web_hook, @web_hook.channels.first, current_user.id

      redirect_to app_web_hooks_path(@app), notice: t('admin.web_hooks.messages.success.test')
    end

    private

    def set_app
      @app = App.find(params[:app_id])
    end

    def load_web_hooks
      @web_hooks = WebHook.where(channel_id: @app.channel_ids).includes(:channels).order(:id)
    end

    def set_web_hook
      @web_hook = WebHook.find(params[:id])
    end

    def selected_channel_ids
      @selected_channel_ids ||= begin
        ids = Array(params.dig(:web_hook, :channel_ids)).reject(&:blank?).map(&:to_i)
        ids & @app.channel_ids
      end
    end

    # Bind the picked channels and mirror the first one onto the owner column, so
    # the single `channel_id` presence validation can never hide the real problem:
    # a hook without any channel must fail on `channel_ids`, which the form renders.
    def assign_channels
      ids = selected_channel_ids
      if ids.empty?
        @web_hook.errors.add(:channel_ids, :blank)
      else
        @web_hook.channel_id = ids.first
        @web_hook.channel_ids = ids
      end
    end

    def web_hook_attributes
      params.require(:web_hook).permit(
        :url, :body, :upload_events, :download_events, :changelog_events
      )
    end
  end
end
