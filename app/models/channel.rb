class Channel < ApplicationRecord
  include FriendlyId

  friendly_id :slug

  belongs_to :scheme
  has_many :releases, dependent: :destroy
  has_many :web_hooks, dependent: :destroy

  enum device_type: { ios: 'iOS', android: 'Android' }

  before_create :generate_default_values

  validates :name, presence: true
  validates :slug, uniqueness: true

  def app
    scheme.app
  end

  def app_name
    "#{app.name} #{name} #{scheme.name}"
  end

  def recently_releases(limit = 10)
    releases.limit(limit).order(id: :desc)
  end

  def release_versions
    releases.group(:release_version)
            .map(&:release_version)
            .reverse
  end

  def release_version_count(version)
    releases.where(release_version: version).count
  end



  # def self.find_by_release(release)
  #   instance = release.app
  #   instance.current_release = release
  #   instance
  # end

  # def platform
  #   case device_type.downcase
  #   when 'iphone', 'ipad', 'ios'
  #     'iOS'
  #   when 'android'
  #     'Android'
  #   else
  #     'Unkown'
  #   end
  # end

  # def branches
  #   Rails.cache.fetch("app_#{id}_branches", expires_in: 1.week) do
  #     releases
  #       .select([:id, 'branch AS name', :app_id, 'COUNT(*) AS count', :created_at])
  #       .group(:branch)
  #       .order(created_at: :desc)
  #       .select { |m| !m.name.to_s.empty? }
  #       .sort_by(&:created_at)
  #       .reverse
  #   end
  # end

  # def release_versions
  #   releases.group(:release_version)
  #           .map(&:release_version)
  #           .reverse
  # end

  # def build_versions(release_version)
  #   releases.where(release_version: release_version)
  #           .group(:build_version)
  #           .map(&:build_version)
  # end

  # def version
  #   current_release.try(:[], :version)
  # end

  # def release_version
  #   current_release.try(:[], :release_version)
  # end

  # def build_version
  #   current_release.try(:[], :build_version)
  # end

  # def changelog(since_release_version: nil, since_build_version: nil)
  #   unless since_release_version.blank? && since_build_version.blank?
  #     previous_release = Release.find_by(
  #       app: self,
  #       release_version: since_release_version,
  #       build_version: since_build_version
  #     )

  #     return releases.where("id > #{previous_release.id}").order(id: :desc).each_with_object([]) do |release, obj|
  #       next if release.changelog.blank? || release.changelog == '[]'

  #       begin
  #         obj.concat JSON.parse(release.changelog)
  #       rescue
  #         obj.concat release.pure_changelog
  #       end
  #     end if previous_release
  #   end

  #   current_release.pure_changelog
  # end

  # def icon_url
  #   current_release.icon.url
  # end

  # def install_url
  #   current_release.install_url
  # end

  # def current_release
  #   @current_release ||= latest_release
  # end

  # def current_release=(current_release)
  #   @current_release = current_release
  # end

  # def latest_release
  #   @latest_release = releases.last
  # end

  private

  def generate_default_values
    self.key = Digest::MD5.hexdigest(File.join(SecureRandom.uuid, name))
    self.slug = Digest::SHA1.base64digest(key).gsub(%r{[+\/=]}, '')[0..4] unless slug.present?
  end
end
