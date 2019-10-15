class DebugFile < ApplicationRecord
  mount_uploader :file, DebugFileUploader

  belongs_to :app
  has_many :metadata, class_name: 'DebugFileMetadatum', dependent: :destroy

  enum device_type: { ios: 'iOS', android: 'Android' }

  validates :app_id, :device_type, :file, presence: true
  validates :release_version, :build_version, presence: true, if: :upload_is_android?
  validates_uniqueness_of :checksum, on: :create

  before_validation :generate_checksum

  private

  def generate_checksum
    self.checksum = file.checksum
  end

  def upload_is_android?
    device_type == 'android'
  end
end
