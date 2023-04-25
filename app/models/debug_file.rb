# frozen_string_literal: true

class DebugFile < ApplicationRecord
  include Rails.application.routes.url_helpers

  default_scope { order(id: :desc) }

  paginates_per     50
  max_paginates_per 100

  mount_uploader :file, DebugFileUploader

  belongs_to :app
  has_many :metadata, class_name: 'DebugFileMetadatum', dependent: :destroy

  enum device_type: { ios: 'iOS', android: 'Android' }

  validates :app_id, :device_type, :file, presence: true
  validates :release_version, :build_version, presence: true, if: :upload_is_android?
  validates :checksum, uniqueness: true, on: :create

  before_validation :generate_checksum

  def self.apps
    App.where(id: select(:app_id).distinct)
  end

  def processing?
    metadata.count.zero?
  end

  def name
    name = main_object.object if device_type == 'iOS'
    name || app.name
  end

  def bundle_id
    case device_type.downcase.to_sym
    when :ios
      main_object.data['identifier']
    when :android
      proguard.object
    end
  end
  alias package_name bundle_id

  # iOS only
  def main_object
    main_objects.first
  end

  # iOS only
  def main_objects
    return metadata unless multi_object?

    metadata.where("data->>'main' = ?", 'true')
  end

  # iOS only
  def archs
    metadata.select(:type).distinct.map(&:type)
  end

  # iOS only
  def libraries
    return [] unless multi_object?

    metadata.where("data->>'main' = ?", 'false')
  end

  # iOS only
  def multi_object?
    metadata.select(:object).distinct.size > 1
  end

  # Android only
  def proguard_files
    proguard&.data&.fetch('files')
  end

  def proguard
    metadata.first
  end

  def download_filename
    "#{app.name}_#{device_type}_#{release_version}_#{build_version}_#{file.file.filename}"
  end

  def filesize
    file&.size
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
