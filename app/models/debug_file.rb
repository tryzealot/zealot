class DebugFile < ApplicationRecord
  mount_uploader :file, DebugFileUploader

  belongs_to :app

  validates :app_id, :release_version, :build_version, :file, presence: true
  validates_uniqueness_of :checksum, on: :create

  before_validation :generate_checksum

  private

  def generate_checksum
    self.checksum = file.checksum
  end
end
