# frozen_string_literal: true

require 'pathname'

class Backup < ApplicationRecord
  scope :enabled_jobs, -> { where(enabled: true) }

  validates :key, uniqueness: true, on: :create
  validates :key, :schedule, presence: true
  validate :correct_schedule

  before_save :strip_enabled_apps
  before_destroy :remove_storage

  after_save :update_worker_scheduler

  def apps
    App.where(id: enabled_apps)
  end

  def perform_job(user_id)
    job = BackupJob.perform_later(id, user_id)
    append_job_to_cache_pool(job)
  end

  def find_file(filename)
    file = Dir.glob(File.join(backup_path, filename)).first
    return unless file

    Pathname.new(file)
  end

  def backup_files
    Dir.glob(File.join(backup_path, '*')).each_with_object([]) do |file, obj|
      backup_file = BackupFile.parse(self, file)
      obj << backup_file
    end.sort_by(&:ctime).reverse!
  end

  def destroy_directory(name)
    FileUtils.rm_rf(File.join(backup_path, name))

    job_id, status = BackupFile.find_job(cache_key, key, name)

    Rails.cache.delete(cache_job_key) if job_id
    status.delete if status
  end

  def cache_job_key
    @cache_job_key ||= "zealot:cache:backup:#{id}"
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

  class BackupFile
    def self.parse(backup, file)
      job_ids = find_job_status(backup.cache_job_key)
      new(file, job_ids)
    end

    def self.find_job_status(cache_key)
      Rails.cache.read(cache_key) || {}
    end

    # def self.find_jobs_status(cache_key)
    #   job_ids = Rails.cache.read(cache_key) || {}
    #   job_ids.each_with_object([]) do |job_id, obj|
    #     obj << ActiveJob::Status.get(job_id)
    #   end
    # end

    attr_reader :job_id, :status

    delegate :size, :ctime, :to_path, :basename, to: :@file

    def initialize(file, job_id)
      @file = Pathname.new(file)
      @job_id = job_id
    end

    def name
      @file.basename
    end

    def created_at
      @file.ctime
    end

    def current_status
      status&.status || (completed? ? 'completed' : 'unknown')
    end

    def completed?
      File.exist?(@file)
    end

    def job
      @job ||= GoodJob::Job.unfinished_undiscrete.where(job_id)
    end
  end

  private

  def append_job_to_cache_pool(job)
    job_id = job.job_id
    created_at = Time.now.utc
    jobs = Rails.cache.fetch(cache_job_key) do
      {
        job_id => created_at
      }
    end

    unless jobs.include?(job_id)
      jobs[job_id] = created_at
      Rails.cache.write(cache_job_key, jobs)
    end

    jobs
  end

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
    FileUtils.rm_rf(path)
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
