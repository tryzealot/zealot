# frozen_string_literal: true

require 'pathname'

class Backup < ApplicationRecord
  validates :key, uniqueness: true, on: :create
  validates :key, :schedule, presence: true
  validate :correct_schedule

  before_save :strip_enabled_apps
  before_destroy :remove_storage

  def apps
    App.where(id: enabled_apps)
  end

  def perform_job
    job = BackupJob.perform_later(id)
    Rails.cache.redis.sadd(cache_job_id_key, job.job_id)
  end

  def find_file(dirname)
    file = Dir.glob(File.join(path, dirname, '*.tar')).first
    return unless file

    Pathname.new(file)
  end

  def files
    # TODO: 需要重写，逻辑有问题
    Dir.glob(File.join(path, '*')).each_with_object([]) do |file, obj|
      backup_file = BackupFile.parse(file, job_status)
      # next unless backup_file.complated?

      obj << backup_file
    end.sort_by(&:ctime).reverse!
  end

  def destroy_directory(name)
    FileUtils.rm_rf(File.join(path, name))

    job_id, status = job_status.find {|_, status| status[:file] == name }

    Rails.cache.redis.srem(cache_job_id_key, job_id) if job_id
    status.delete if status
  end

  def job_status
    job_ids = Rails.cache.redis.smembers(cache_job_id_key)
    return {} if job_ids.empty?

    job_ids.each_with_object({}) do |job_id, obj|
      obj[job_id] = ActiveJob::Status.get(job_id)
    end
  end

  def cache_job_id_key
    @cache_job_id_key ||= "zealot:backup:#{id}"
  end

  def path
    Rails.root.join(Setting.backup[:path], key)
  end

  class BackupFile
    def self.parse(file, backup_job_status)
      job_id, status = backup_job_status.find {|_, status| status[:file] == File.basename(file) }
      new(file, status)
    end

    attr_reader :status

    delegate :size, :ctime, :to_path, :basename, to: :@file

    def initialize(file, status)
      @file = Pathname.new(file)
      @status = status
    end

    def created_at
      @file.ctime
    end

    def job_status
      @status&.status || (complated? ? 'complated' : 'unknown')
    end

    def complated?
      file = File.join(@file.to_path, ".complate")
      File.exist?(file)
    end

    def failure
      return unless @status

      failures = Sidekiq::Failures::FailureSet.new
      failures.find do |failure|
        failure.jid == @status[:jid]
      end
    end
  end

  private

  def correct_schedule
    parser = Fugit.do_parse(self.schedule)
    klass = parser.class

    raise ArgumentError, "Not cron: #{klass}" unless klass == Fugit::Cron
  rescue => e
    logger.error "schedule parse error: #{e}"
    errors.add(:schedule, :invalid)
  end

  def strip_enabled_apps
    enabled_apps.compact!
  end

  def remove_storage
    FileUtils.rm_rf(path)
  end
end
