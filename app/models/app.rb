class App < ActiveRecord::Base
  has_many :releases
  belongs_to :user

  validates :name, :identifier, :device_type, presence: true
  validates :slug, uniqueness: true

  before_create :generate_key_or_slug

  def self.latest(identifier)
    self.where(identifier:identifier).order('created_at DESC').first
  end

  private
    def generate_key_or_slug
      self.key = SecureRandom.uuid + self.identifier
      unless self.slug
        self.slug = Digest::SHA1.base64digest(self.key).gsub(/[+\/=]/, '')[0..4]
      end
    end
end
