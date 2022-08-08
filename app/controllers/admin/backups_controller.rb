# frozen_string_literal: true

class Admin::BackupsController < ApplicationController
  before_action :set_backup, except: %i[ index new create ]
  before_action :set_backup_file, only: %i[ download_archive destroy_archive ]

  def index
    @backups = Backup.all
    authorize @backups
  end

  def show
    @backup_files = @backup.backup_files
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
    @backup.perform_job

    notice = 'Backup was successfully scheduled to run in the background.'
    redirect_back_or_to admin_backups_path, notice: notice
  end

  def download_archive
    raise ActiveRecord::RecordNotFound, 'Not found file' unless File.exist?(@backup_file)

    headers['Content-Length'] = @backup_file.size
    send_file @backup_file.to_path, type: 'application/x-tar', disposition: 'attachment'
  end

  def destroy_archive
    @backup.destroy_directory(@backup_dir)
    redirect_to admin_backup_path(@backup), status: :see_other, notice: t('.file_destroy_success')
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

    redirect_to admin_backups_path #, notice: t('admin.apple_keys.create.successful')
  end

  def update
    return render :edit, status: :unprocessable_entity unless @backup.update(backup_params)

    redirect_to admin_backups_path
  end

  def destroy
    @backup.destroy
    notice = t('activerecord.success.destroy', key: t('admin.backups.title'))
    redirect_to admin_backups_url, status: :see_other, notice: notice
  end

  def parse_schedule
    parser = Fugit.parse(params[:q])

    if parser
      body = if parser.is_a?(Fugit::Cron)
        {
          schedule: true,
          cron: parser.to_cron_s,
          next_time: parser.next_time.to_s
        }
      else
        {
          schedule: false,
          run_once: parser.to_s
        }
      end

      return render json: body, status: 200
    end

    render json: {
      error: 'Can not parse',
      q: params[:q]
    }, status: 401
  end

  private

  def set_backup
    @backup = Backup.find(params[:id])
    authorize @backup
  end

  def set_backup_file
    @backup_dir = params[:key]
    @backup_file = @backup.find_file(@backup_dir)
  end

  def backup_params
    @backup_params ||= params.require(:backup).permit(
      :key, :schedule, :max_keeps, :enabled, :notification,
      :enabled_database, enabled_apps: []
    )
  end
end
