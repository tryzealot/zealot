class Dsym < ApplicationRecord
  mount_uploader :file, DsymFileUploader

  belongs_to :app

  before_validation :generate_file_hash

  validates :app_id, :release_version, :build_version, :file, presence: true
  validates_uniqueness_of :file_hash, :on => :create

  private

  def generate_file_hash
    self.file_hash = file.md5
  end
end
