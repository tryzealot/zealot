# frozen_string_literal: true

class Channel < ApplicationRecord
  include RecentlyReleasesCacheable

  default_scope { order(id: :asc) }

  include FriendlyId
  include VersionCompare

  friendly_id :slug

  belongs_to :scheme
  has_many :releases, dependent: :destroy
  has_and_belongs_to_many :web_hooks, dependent: :destroy

  enum :device_type, {
    ios: 'iOS', android: 'Android', harmonyos: 'HarmonyOS',
    macos: 'macOS', windows: 'Windows', linux: 'Linux'
  }

  DEFAULT_DOWNLOAD_FILENAME_TYPE = :version_datetime

  enum :download_filename_type, {
    version_datetime: 'version_datetime',
    original_filename: 'original_filename'
  }

  delegate :count, to: :enabled_web_hooks, prefix: true
  delegate :count, to: :available_web_hooks, prefix: true
  delegate :app, to: :scheme

  before_create :generate_default_values
  before_save :generate_default_values, if: -> { slug.blank? }
  after_destroy :delete_app_recently_releases_cache

  validates :name, presence: true
  validates :slug, uniqueness: true
  validates :device_type, presence: true, inclusion: { in: self.device_types.keys }
  validates :download_filename_type, presence: true, inclusion: { in: self.download_filename_types.keys }

  before_validation :set_default_download_filename_type, on: :create

  def latest_release
    releases.last
  end

  def recently_releases(limit = Setting.per_page, page: 1)
    releases.page(page).per(limit).order(id: :desc)
  end

  # Find new releases by given arguments, following rules:
  #
  # 1. Find given release then find all new release after given release
  # 2. Or from newer versions to comapre and return
  # *) Given version always convert semver styled value
  def find_since_version(bundle_id, release_version, build_version)
    current_release = releases.select(:id).find_by(
      bundle_id: bundle_id,
      release_version: release_version,
      build_version: build_version
    )

    prepared_releases = if current_release
      releases.where('id > ?', current_release.id).order(id: :desc)
    else
      newer_versions = release_versions.select { |version| ge_version(version, release_version) }
      releases.where(
          bundle_id: bundle_id,
          release_version: newer_versions,
        )
        .order(id: :desc)
    end

    prepared_releases.select { |release|
      ge_version(release.release_version, release_version) &&
        gt_version(release.build_version, build_version)
    }
  end

  def app_name
    "#{app.name} #{channel_name}"
  end

  def channel_name
    "#{scheme.name} #{name}"
  end

  def release_versions(limit = 10)
    versions = releases.select(:release_version)
      .where.not(release_version: nil)
      .group(:release_version)
      .map(&:release_version)
      .reject(&:blank?)
      .sort do |a,b|
        begin
          version_compare(b, a)
        rescue ArgumentError => e
          # Note: 处理版本号是 android-1.2.3 类似非标版本号的异常，如有发现就放最后面
          # 后续如果有人反馈问题多了再说，看到本注释的请告知遵守版本号标准
          e.message.include?(a) ? 1 : -1
        end
      end

    return versions if limit.blank? || limit <= 0

    versions.size >= limit ? versions[0..limit - 1] : versions
  end

  def release_version_count(version)
    releases.where(release_version: version).count
  end

  def bundle_id_matched?(value)
    return true if bundle_id.blank? || bundle_id == '*'
    return false if value.blank? # TODO: need verify why it empty(can not parse bundle id or package name or empty)

    value.match?(bundle_id)
  end

  def perform_web_hook(event_name, user_id)
    web_hooks.where(event_name => 1).find_each do |web_hook|
      AppWebHookJob.perform_later event_name, web_hook, self, user_id
    end
  end

  def enabled_web_hooks
    web_hooks
  end

  def available_web_hooks
    ChannelsWebHook.select(:web_hook_id).distinct
                   .where.not(web_hook_id: web_hooks.select(:id))
                   .where.not(channel_id: id)
                   .each_with_object([]) do |item, obj|
      obj << item.web_hook if item.web_hook.present?
    end
  end

  def encode_password
    Digest::MD5.hexdigest(password)
  end

  def devices
    releases.distinct.left_joins(:devices)
  end

  private

  def generate_default_values
    self.key = Digest::MD5.hexdigest(File.join(SecureRandom.uuid, name))
    self.slug = Digest::SHA1.base64digest(key).gsub(%r{[+\/=]}, '')[0..4] if slug.blank?
  end

  def recently_release_cache_key
    @recently_release_cache_key ||= "app_#{app.id}_recently_release"
  end

  def delete_app_recently_releases_cache
    Rails.cache.delete(recently_release_cache_key)
  end

  def set_default_download_filename_type
    self.download_filename_type ||= DEFAULT_DOWNLOAD_FILENAME_TYPE
  end

  def recently_release_app_id
    app.id
  end
end
