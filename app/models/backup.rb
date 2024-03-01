# frozen_string_literal: true

require 'pathname'

class Backup < ApplicationRecord
  include BackupFile

  scope :enabled_jobs, -> { where(enabled: true) }

  validates :key, uniqueness: true, on: :create
  validates :key, :schedule, presence: true
  validate :correct_schedule

  before_save :strip_enabled_apps
  after_save :update_worker_scheduler

  before_destroy :remove_storage

  def apps
    App.where(id: enabled_apps)
  end

  def perform_job(user_id)
    BackupJob.perform_later(id, user_id)
  end

  def find_file(filename)
    file = Dir.glob(File.join(backup_path, filename)).first
    return unless file

    Pathname.new(file)
  end

  def backup_files
    Dir.glob(File.join(backup_path, '*.tar')).each_with_object([]) do |file, obj|
      backup_file = BackupFile.new(file)
      next unless backup_file.completed?

      obj << backup_file
    end.sort_by(&:ctime).reverse!
  end

  def performing_jobs
    jobs = GoodJob::Job.where(job_class: 'BackupJob')
      .where("serialized_params#>>'{arguments,0}' = ?", id.to_s)
      .order(created_at: :desc)

    jobs.each_with_object([]) do |good_job, obj|
      next if good_job.succeeded?

      activejob_status = ActiveJob::Status.get(good_job.id)
      job = PerformingJob.new(good_job, activejob_status)
      obj << job
    end
  end

  def destroy_directory(name)
    Dir.glob(File.join(backup_path, "#{name}*")).each do |file|
      FileUtils.rm_rf(file)
    end
  end

  def remove_background_jobs(job_id = nil)
    status = ActiveJob::Status.get(job_id)
    if status.present?
      backup_file = status[:file]
      destroy_directory(backup_file)
      status.delete
    end

    GoodJob::Job.destroy(job_id)
  end

  def backup_path
    @backup_path ||= Rails.root.join(Setting.backup[:path], key)
  end

  def schedule_job
    data = []
    data << 'database' if enabled_database
    data << "#{enabled_apps.size} apps" if enabled_apps

    {
      description: "Backup zealot #{data.join(' | ')} data",
      cron: Fugit.parse(schedule).to_cron_s,
      class:'BackupJob',
      args: [ id ]
    }
  end

  def schedule_key
    @scheduler_key ||= "zealot_backup_#{key}".to_sym
  end

  private

  # def append_job_to_cache_pool(job)
  #   job_id = job.job_id
  #   jobs = Rails.cache.fetch(cache_job_key) do
  #     [ job_id ]
  #   end

  #   unless jobs.include?(job_id)
  #     jobs << job_id
  #     Rails.cache.write(cache_job_key, jobs)
  #   end

  #   jobs
  # end

  def correct_schedule
    parser = Fugit.do_parse(self.schedule)
    klass = parser.class

    raise ArgumentError, "Not match cron expression: #{klass}" unless klass == Fugit::Cron
  rescue ArgumentError => e
    errors.add(:schedule, :invalid)
  end

  def strip_enabled_apps
    enabled_apps.compact!
  end

  def remove_storage
    FileUtils.rm_rf(backup_path)
  end

  def update_worker_scheduler
    # FIXME: This class exists, must rename new one, may be SchedulerExt?
    # code: lib/good_lib/good_job_ext.rb
    #
    # scheduler = GoodJob::Scheduler.new
    # has_cron = scheduler.key?(schedule_key)
    # return if has_cron && enabled

    # if enabled
    #   scheduler.add(schedule_key, schedule_job) unless has_cron
    # else
    #   scheduler.remove(schedule_key) if has_cron
    # end

    configuration = GoodJob.configuration
    cron = configuration.cron
    has_cron = cron.key?(schedule_key)
    return if has_cron && enabled

    if enabled && !has_cron
      cron[schedule_key] = schedule_job
    elsif !enabled && has_cron
      cron.delete(schedule_key)
    end

    # NOTE: no needs
    # capsule = GoodJob::Capsule.new(configuration: configuration)
    # GoodJob.capsule = capsule
    # capsule.restart
  end
end
