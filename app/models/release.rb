# frozen_string_literal: true

require 'app-info'

class Release < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  scope :latest, -> { order(version: :desc).first }

  belongs_to :channel

  validates :bundle_id, :release_version, :build_version, :file, presence: true
  validate :force_bundle_id, on: :create

  before_create :auto_release_version
  before_create :auto_file_size
  before_create :default_source
  before_save   :changelog_format, if: :changelog_is_not_json?

  paginates_per     20
  max_paginates_per 50

  def self.find_by_channel(slug, version = nil)
    channel = Channel.friendly.find slug
    if version
      channel.releases.find_by version: version
    else
      channel.releases.latest
    end
  end

  # 上传 App
  def self.upload_file(params, source = 'Web')
    create(params) do |release|
      unless release.file.blank?
        app_info = AppInfo.parse(release.file.path)
        release.source = source
        release.bundle_id = app_info.bundle_id
        release.release_version = app_info.release_version
        release.build_version = app_info.build_version
        release.release_type ||= app_info.release_type if app_info.os == AppInfo::Platform::IOS

        if icon_file = app_info.icons.last.try(:[], :file)
          release.icon = decode_icon(icon_file)
        end
      end
    end
  end

  def self.decode_icon(icon_file)
    Pngdefry.defry icon_file, icon_file
    File.open icon_file
  end
  private_class_method :decode_icon

  def scheme
    channel.scheme
  end

  def app
    scheme.app
  end

  def app_name
    "#{app.name} #{channel.name} #{scheme.name}"
  end

  def device_type
    channel.device_type
  end

  def short_git_commit
    return nil if git_commit.blank?

    git_commit[0..8]
  end

  def changelog_list(use_default_changelog = true)
    return empty_changelog(use_default_changelog) if changelog.blank?

    data = JSON.parse changelog
    return empty_changelog(use_default_changelog) if data.empty?

    data
  end

  def devices_list
    return [] if devices.blank?

    data = devices.to_json
    return [] if data.empty?

    data
  end

  def install_url
    return api_v2_apps_download_url(channel.slug, version) if channel.device_type.casecmp('android').zero?

    download_url = api_v2_apps_install_url(
      channel.slug, version,
      protocol: Rails.env.development? ? 'http' : 'https'
    )
    "itms-services://?action=download-manifest&url=#{download_url}"
  end

  def release_url
    channel_release_url channel, self
  end

  def qrcode_url(size = :thumb)
    channel_release_qrcode_index_url channel, self, size: size
  end

  def file_extname
    case channel.device_type.downcase
    when 'iphone', 'ipad', 'ios', 'universal'
      '.ipa'
    when 'android'
      '.apk'
    else
      '.ipa_or_apk.zip'
    end
  end

  def download_filename
    [
      channel.slug, release_version, build_version, created_at.strftime('%Y%m%d%H%M')
    ].join('_') + file_extname
  end

  def mime_type
    case channel.device_type
    when 'iOS'
      :ipa
    when 'Android'
      :apk
    end
  end

  def empty_changelog(use_default_changelog = true)
    return [] unless use_default_changelog

    @empty_changelog ||= [
      {
        'message' => "没有找到更新日志，可能的原因：\n\n- 开发者很懒没有留下更新日志😂\n- 有不可抗拒的因素造成日志丢失👽",
        # date: Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      }
    ]
  end

  def outdated?
    lastest = channel.releases.last

    return lastest if lastest.id > id
  end

  def force_bundle_id
    return if file.blank?
    return if channel.bundle_id.blank?
    return if channel.bundle_id_matched?(app_info.bundle_id)

    message = "#{channel.app_name} 的 bundle id `#{app_info.bundle_id}` 无法和 `#{channel.bundle_id}` 匹配"
    errors.add(:file, message)
  end

  private

  def auto_release_version
    latest_version = Release.where(channel: channel).limit(1).order(id: :desc).last
    self.version = latest_version ? (latest_version.version + 1) : 1
  end

  def auto_file_size
    self.size = file.size if file.present? && file_changed?
  end

  def changelog_format
    hash = []
    changelog.split("\n").each do |message|
      next if message.blank?

      hash << { message: message }
    end
    self.changelog = hash.to_json
  end

  def default_source
    self.source ||= 'API'
  end

  def changelog_is_not_json?
    return false if changelog.blank?

    JSON.parse changelog
    false
  rescue JSON::ParserError
    true
  end

  def enabled_validate_bundle_id?
    bundle_id = channel.bundle_id
    !(bundle_id.blank? || bundle_id == '*')
  end

  def app_info
    @app_info ||= AppInfo.parse(file.file.file)
  end
end
