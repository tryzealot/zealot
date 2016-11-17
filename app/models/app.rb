class App < ActiveRecord::Base
  include FriendlyId
  friendly_id :slug

  has_many :releases, dependent: :destroy
  has_many :web_hooks, dependent: :destroy
  belongs_to :user

  validates :name, :identifier, :device_type, presence: true
  validates :slug, uniqueness: true

  before_create :generate_key_or_slug

  def platform
    case device_type.downcase
    when 'iphone', 'ipad', 'ios'
      'iOS'
    when 'android'
      'Android'
    else
      'Unkown'
    end
  end

  def branches
    Rails.cache.fetch("app_#{id}_branches", expires_in: 1.week) do
      releases
        .select([:id, 'branch AS name', :app_id, 'COUNT(*) AS count', :created_at])
        .group(:branch)
        .order(created_at: :desc)
        .select { |m| !m.name.to_s.empty? }
        .sort_by(&:created_at)
        .reverse
    end
  end

  def release_versions
    releases.group(:release_version)
            .map(&:release_version)
  end

  def build_versions(release_version)
    releases.where(release_version: release_version)
            .group(:build_version)
            .map(&:build_version)
  end

  private

  def generate_key_or_slug
    self.key = Digest::MD5.hexdigest(SecureRandom.uuid + identifier)
    self.slug = Digest::SHA1.base64digest(key).gsub(%r{[+\/=]}, '')[0..4] unless slug
  end
end
