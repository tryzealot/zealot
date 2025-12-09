# frozen_string_literal: true

class Admin::BackupsController < ApplicationController
  before_action :set_backup, except: %i[ index new create parse_schedule ]

  def index
    @backups = Backup.all
    authorize @backups
  end

  def show
    @backup_files = @backup.backup_files
    @performing_jobs = @backup.performing_jobs
  end

  def enable
    @backup.update(enabled: true)
    redirect_to admin_backups_path
  end

  def disable
    @backup.update(enabled: false)
    redirect_to admin_backups_path
  end

  def perform
    if @backup.max_keeps.zero?
      alert = t('active_job.backup.failures.max_keeps_limited',
        key: @backup.key,
        count: @backup.max_keeps
      )

      return redirect_back_or_to admin_backups_path, alert: alert
    end

    @backup.perform_job(current_user.id)
    redirect_back_or_to admin_backups_path, notice: t('.success', key: @backup.key)
  end

  def download_archive
    backup_file = @backup.find_file(params[:key])
    raise ActiveRecord::RecordNotFound, 'Not found file' unless File.exist?(backup_file)

    headers['Content-Length'] = backup_file.size
    send_file backup_file.to_path, type: 'application/x-tar', disposition: 'attachment'
  end

  def destroy_archive
    @backup.destroy_directory(params[:key])
    redirect_to admin_backup_path(@backup), status: :see_other, notice: t('.success', key: @backup.key)
  end

  def cancel_job
    @backup.remove_background_jobs(params[:job_id])
    redirect_to admin_backup_path(@backup), status: :see_other, notice: t('.success', key: @backup.key)
  end

  def new
    @backup = Backup.new
    authorize @backup
  end

  def edit
  end

  def create
    @backup = Backup.new(backup_params)
    authorize @backup

    return render :new, status: :unprocessable_entity unless @backup.save

    flash.now[:notice] = t('activerecord.success.create', key: t('admin.backups.title'))
    respond_to do |format|
      format.html { redirect_to admin_backups_path }
      format.turbo_stream
    end
  end

  def update
    return render :edit, status: :unprocessable_entity unless @backup.update(backup_params)

    flash.now[:notice] = t('activerecord.success.update', key: t('admin.backups.title'))
    respond_to do |format|
      format.html { redirect_to admin_backups_path }
      format.turbo_stream
    end
  end

  def destroy
    @backup.destroy

    flash.now[:notice] = t('activerecord.success.destroy', key: t('admin.backups.title'))
    respond_to do |format|
      format.html { redirect_to admin_backups_url }
      format.turbo_stream
    end
  end

  def parse_schedule
    parser = Fugit.parse(params[:q])
    if parser && parser.is_a?(Fugit::Cron)
      return render json: {
        schedule: true,
        cron: parser.to_cron_s,
        next_time: helpers.l(helpers.next_schedule_time(parser), format: :nice)
      }, status: 200
    end

    render json: {
      error: t('.invalid_expression')
    }, status: 409
  end

  private

  def set_backup
    @backup = Backup.find(params[:id])
    authorize @backup
  end

  def backup_params
    @backup_params ||= params.require(:backup).permit(
      :key, :schedule, :max_keeps, :enabled, :notification,
      :enabled_database, enabled_apps: []
    )
  end
end
