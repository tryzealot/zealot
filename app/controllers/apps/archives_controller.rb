# frozen_string_literal: true

class Apps::ArchivesController < ApplicationController
  include AppListScope

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response

  before_action :set_app, only: %i[update destroy]

  def update
    authorize @app, :archive?

    unless @app.archive
      alert = t('activerecord.errors.messages.unknown', key: t('apps.show.archive_app'))
      return redirect_to app_list_redirect_path, alert: alert
    end

    notice = t('activerecord.success.archived', key: "#{@app.name} #{t('apps.title')}")
    prepare_list

    respond_to do |format|
      format.html { redirect_to app_list_redirect_path, notice: notice }
      format.turbo_stream { flash.now[:notice] = notice }
    end
  end

  def destroy
    authorize @app, :unarchive?

    unless @app.unarchive
      alert = t('activerecord.errors.messages.unknown', key: t('apps.show.unarchive_app'))
      return redirect_to app_list_redirect_path, alert: alert
    end

    @app.update(archived: false)

    notice = t('activerecord.success.unarchived', key: "#{@app.name} #{t('apps.title')}")
    prepare_list

    respond_to do |format|
      format.html { redirect_to app_list_redirect_path, notice: notice }
      format.turbo_stream { flash.now[:notice] = notice }
    end
  end

  private

  def prepare_list
    @scope = resolved_scope
    @sort = resolved_sort
    @apps = app_list_base_scope.search_by_name(params[:search]).by_scope(@scope)
  end

  def set_app
    @app = org_scope(App).find(params[:id])
  end

  def render_not_found_entity_response(e)
    return not_found(e) unless e.model == 'App'

    redirect_to apps_path, alert: t('apps.messages.failture.not_found_app', id: e.id)
  end
end
