# frozen_string_literal: true

require 'pathname'

class Backup < ApplicationRecord
  has_many :backup_scopes

  def perform_job
    BackupJob.perform_later id
  end

  def backup_database?
    backup_scopes.database?
  end

  def backup_channel?
    backup_scopes.channel?
  end

  def files
    Dir.glob(File.join(path, '*')).each_with_object([]) do |file, obj|
      obj << Pathname.new(file)
    end.sort_by(&:ctime).reverse!
  end

  def path
    Rails.root.join(Setting.backup[:path], key)
  end
end
