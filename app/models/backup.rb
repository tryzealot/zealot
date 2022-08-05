# frozen_string_literal: true

require 'pathname'

class Backup < ApplicationRecord
  validates :key, uniqueness: true, on: :create
  validates :key, :schedule, presence: true
  validate :correct_schedule

  before_save :strip_enabled_channels
  before_destroy :remove_storage

  def channels
    Channel.where(id: enabled_channels)
  end

  def perform_job
    BackupJob.perform_later id
  end

  def find_file(dirname)
    # has_lock_file = File.exist?(File.join(dirname, '.lock'))
    file = Dir.glob(File.join(path, dirname, '*.tar')).first
    raise ActiveRecord::RecordNotFound, "Not found backup in path: #{dirname}" unless file

    Pathname.new(file)
  end

  def files
    Dir.glob(File.join(path, '*')).each_with_object([]) do |file, obj|
      obj << Pathname.new(file)
    end.sort_by(&:ctime).reverse!
  end

  def path
    Rails.root.join(Setting.backup[:path], key)
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

  def strip_enabled_channels
    enabled_channels.compact!
  end

  def remove_storage
    FileUtils.rm_rf(path)
  end
end
