class App < ActiveRecord::Base
  has_many :releases

  validates :name, presence: true
  validates :identifier, presence: true
  validates :device_type, presence: true

  before_create :generate_key_or_slug

  def self.latest(identifier)
    self.where(identifier:identifier).order('created_at DESC').first
  end

  private
    def generate_key_or_slug
      self.key = Digest::MD5.hexdigest(self.name + "!@#" + self.identifier)
      unless self.slug
        self.slug = Digest::SHA1.base64digest(self.key)[0..4]
      end
    end
end
