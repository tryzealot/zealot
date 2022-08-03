# frozen_string_literal: true

class Admin::BackupsController < ApplicationController
  before_action :set_backup, only: %i[show perform edit update destroy]

  def index
    @backups = Backup.all
  end

  def show
  end

  def perform
    @backup.perform_job

    notice = 'Backup was successfully scheduled to run in the background.'
    redirect_to admin_backups_path, notice
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def new
  end

  def create
  end

  private

  def set_backup
    @backup = Backup.find(params[:id])
  end
end
