class App < ActiveRecord::Base
  has_many :releases
  belongs_to :user

  validates :name, :identifier, :device_type, presence: true
  validates :slug, uniqueness: true

  before_create :generate_key_or_slug

  def branches
    Rails.cache.fetch("app_#{self.id}_branches", expires_in: 1.week) do
      self.releases
        .select([:id, "branch AS name", :app_id, "COUNT(*) AS count", :created_at])
        .group(:branch)
        .order(created_at: :desc)
        .select { |m| ! m.name.to_s.empty? }
        .sort_by { |m| m.created_at }
        .reverse
    end
  end

  def self.latest(identifier)
    self.where(identifier:identifier).order('created_at DESC').first
  end

  private
    def generate_key_or_slug
      self.key = Digest::MD5.hexdigest(SecureRandom.uuid + self.identifier)
      unless self.slug
        self.slug = Digest::SHA1.base64digest(self.key).gsub(/[+\/=]/, '')[0..4]
      end
    end
end
