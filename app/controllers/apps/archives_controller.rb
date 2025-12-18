# frozen_string_literal: true

class Apps::ArchivesController < ApplicationController
  before_action :set_app, only: %i[update destroy]

  def index
    @title = t('apps.archives.title')
    base_scope = manage_user_or_guest_mode? ? App.archived : current_user.apps.archived
    base_scope = params[:search].present? ? base_scope.search_by_name(params[:search]) : base_scope
    @apps = params[:sort].present? ? base_scope.sort_by_name(params[:sort]) : base_scope
    authorize @apps if @apps.present?

    render 'apps/index'
  end

  def update
    authorize @app, :archive?
    @apps = manage_user_or_guest_mode? ? App.active : current_user.apps.active
    
    alert = t('activerecord.errors.messages.unknown', key: t('apps.show.archive_app'))
    return  redirect_to apps_path(@app), alert: alert unless @app.archive

    notice = t('activerecord.success.archived', key: "#{@app.name} #{t('apps.title')}")
    flash.now[:notice] = notice
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.turbo_stream
    end
  end

  def destroy
    authorize @app, :unarchive?
    alert = t('activerecord.errors.messages.unknown', key: t('apps.show.unarchive_app'))
    return redirect_to apps_path(@app), alert: alert unless @app.unarchive

    @apps = manage_user_or_guest_mode? ? App.archived : current_user.apps.unarchive
    notice = t('activerecord.success.unarchived', key: "#{@app.name} #{t('apps.title')}")
    flash.now[:notice] = notice
    respond_to do |format|
      format.html { redirect_to apps_path, notice: t('apps.unarchived.success') }
      format.turbo_stream
    end
  end

  private

  def set_app
    @app = App.find(params[:id])
  end
end
