# frozen_string_literal: true

class DebugFile < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :file, DebugFileUploader

  belongs_to :app
  has_many :metadata, class_name: 'DebugFileMetadatum', dependent: :destroy

  enum device_type: { ios: 'iOS', android: 'Android' }

  validates :app_id, :device_type, :file, presence: true
  validates :release_version, :build_version, presence: true, if: :upload_is_android?
  validates :checksum, uniqueness: true, on: :create

  before_validation :generate_checksum

  def multi_dsym?
    metadata.select(:object).distinct.size > 1
  end

  def download_filename
    "#{app.name}_#{device_type}_#{release_version}_#{build_version}_#{file.file.filename}"
  end

  def file?
    return false if file.blank?

    File.exist?(file.path)
  end

  def file_url
    download_debug_file_url(id)
  end

  private

  def generate_checksum
    self.checksum = file.checksum
  end

  def upload_is_android?
    device_type == 'android'
  end
end
