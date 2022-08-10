# frozen_string_literal: true

class Channel < ApplicationRecord
  include FriendlyId

  friendly_id :slug

  belongs_to :scheme
  has_many :releases, dependent: :destroy
  has_and_belongs_to_many :web_hooks, dependent: :destroy

  enum device_type: { ios: 'iOS', android: 'Android', macos: 'macOS' }

  scope :all_appnames, -> { all.map { |c| [c.app_name, c.id] } }

  delegate :count, to: :enabled_web_hooks, prefix: true
  delegate :count, to: :available_web_hooks, prefix: true
  delegate :app, to: :scheme

  before_create :generate_default_values

  validates :name, presence: true
  validates :slug, uniqueness: true

  def latest_release
    releases.last
  end

  def recently_releases(limit = 10)
    releases.limit(limit).order(id: :desc)
  end

  def find_since_version(bundle_id, release_version, build_version)
    releases.where("release_version >= '#{release_version}'")
            .where("build_version > '#{build_version}'")
            .where(bundle_id: bundle_id)
            .order(id: :desc)
  end

  def app_name
    "#{app.name} #{scheme.name} #{name}"
  end

  def release_versions(limit = 10)
    versions = releases.select(:release_version)
                       .group(:release_version)
                       .map(&:release_version)
                       .sort do |a,b|
                         begin
                           Gem::Version.new(b) <=> Gem::Version.new(a)
                         rescue ArgumentError => e
                           # Note: 处理版本号是 android-1.2.3 类似非标版本号的异常，如有发现就放最后面
                           # 后续如果有人反馈问题多了再说，看到本注释的请告知遵守版本号标准
                           e.message.include?(a) ? 1 : -1
                         end
                       end
    versions.size >= limit ? versions[0..limit - 1] : versions
  end

  def release_version_count(version)
    releases.where(release_version: version).count
  end

  def bundle_id_matched?(value)
    return true if bundle_id.blank? || bundle_id == '*'

    value.match?(bundle_id)
  end

  def perform_web_hook(event_name)
    web_hooks.where(event_name => 1).find_each do |web_hook|
      AppWebHookJob.perform_later event_name, web_hook, self
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
end
