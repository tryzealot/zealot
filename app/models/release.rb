# frozen_string_literal: true

class Release < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  scope :latest, -> { order(version: :desc).first }

  belongs_to :channel

  validates :bundle_id, :release_version, :build_version, :file, presence: true
  validate :bundle_id_matched, on: :create

  before_create :auto_release_version
  before_create :default_source
  before_create :default_changelog
  before_save   :changelog_format, if: :changelog_is_plaintext?

  delegate :scheme, :device_type, to: :channel
  delegate :app, to: :scheme

  paginates_per     20
  max_paginates_per 50

  def self.version_by_channel(slug, version = nil)
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
      if release.file.present?
        begin
          parser = AppInfo.parse(release.file.path)
          release.source = source
          release.bundle_id = parser.bundle_id
          release.release_version = parser.release_version
          release.build_version = parser.build_version

          if parser.os == AppInfo::Platform::IOS
            release.release_type ||= parser.release_type

            icon_file = parser.icons.last.try(:[], :file)
            release.icon = decode_icon(icon_file) if icon_file
          else
            # 处理 Android anydpi 自适应图标
            icon_file = parser.icons
                              .reject { |f| File.extname(f[:file]) == '.xml' }
                              .last
                              .try(:[], :file)
            release.icon = File.open(icon_file, 'rb') if icon_file
          end

          # iOS 且是 AdHoc 尝试解析 UDID 列表
          if parser.os == AppInfo::Platform::IOS &&
             parser.release_type == AppInfo::IPA::ExportType::ADHOC &&
             parser.devices.present?
            release.devices = parser.devices
          end
        rescue AppInfo::UnkownFileTypeError
          release.errors.add(:file, '上传的应用无法正确识别')
        end
      end
    end
  end

  def self.decode_icon(icon_file)
    Pngdefry.defry icon_file, icon_file
    File.open icon_file
  end
  private_class_method :decode_icon

  def app_name
    "#{app.name} #{channel.name} #{scheme.name}"
  end

  def size
    file&.size
  end
  alias file_size size

  def short_git_commit
    return nil if git_commit.blank?

    git_commit[0..8]
  end

  def changelog_list(use_default_changelog = true)
    return empty_changelog(use_default_changelog) if changelog.empty?

    changelog
  end

  def download_url
    api_apps_download_url(channel.slug, version)
  end

  def install_url
    return download_url if channel.device_type.casecmp('android').zero?

    download_url = api_apps_install_url(
      channel.slug, version,
      protocol: Rails.env.development? ? 'http' : 'https'
    )
    "itms-services://?action=download-manifest&url=#{download_url}"
  end

  def release_url
    channel_release_url channel, self
  end

  def qrcode_url(size = :thumb)
    channel_release_qrcode_url channel, self, size: size
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

    @empty_changelog ||= [{
      'message' => "没有找到更新日志，可能的原因：\n\n- 开发者很懒没有留下更新日志😂\n- 有不可抗拒的因素造成日志丢失👽",
    }]
  end

  def outdated?
    lastest = channel.releases.last

    return lastest if lastest.id > id
  end

  def bundle_id_matched
    return if file.blank? || channel&.bundle_id.blank?
    return if app_info.blank? || channel.bundle_id_matched?(app_info.bundle_id)

    message = "#{channel.app_name} 的 bundle id `#{app_info.bundle_id}` 无法和 `#{channel.bundle_id}` 匹配"
    errors.add(:file, message)
  end

  def app_info
    @app_info ||= AppInfo.parse(file.path)
  rescue AppInfo::UnkownFileTypeError
    errors.add(:file, '上传的文件不是有效应用格式')
    nil
  end

  private

  def auto_release_version
    latest_version = Release.where(channel: channel).limit(1).order(id: :desc).last
    self.version = latest_version ? (latest_version.version + 1) : 1
  end

  def changelog_format
    hash = []
    changelog.split("\n").each do |message|
      next if message.blank?

      hash << { message: message }
    end
    self.changelog = hash
  end

  def default_source
    self.source ||= 'API'
  end

  def default_changelog
    self.changelog ||= []
  end

  def changelog_is_plaintext?
    return false if changelog.blank?

    changelog.is_a?(String)
  end

  def enabled_validate_bundle_id?
    bundle_id = channel.bundle_id
    !(bundle_id.blank? || bundle_id == '*')
  end
end
