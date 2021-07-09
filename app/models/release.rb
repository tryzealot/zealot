# frozen_string_literal: true

class Release < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  scope :latest, -> { order(version: :desc).first }

  belongs_to :channel
  has_one :metadata, class_name: 'Metadatum', dependent: :destroy
  has_and_belongs_to_many :devices

  validates :bundle_id, :release_version, :build_version, :file, presence: true
  validate :bundle_id_matched, on: :create

  before_create :auto_release_version
  before_create :default_source
  before_save   :convert_changelog
  before_save   :convert_custom_fields
  before_save   :trip_branch
  before_save   :detect_device

  delegate :scheme, to: :channel
  delegate :app, to: :scheme

  paginates_per     20
  max_paginates_per 50

  def self.version_by_channel(channel_slug, release_id)
    channel = Channel.friendly.find(channel_slug)
    channel.releases.find(release_id)
  end

  # 上传pp
  def self.upload_file(params, parser = nil)
    logger.debug "upload file params: #{params}"
    create(params) do |release|
      if release.file.present?
        begin
          parser ||= AppInfo.parse(release.file.path)
          release.source ||= 'Web'
          release.name = parser.name
          release.bundle_id = parser.bundle_id
          release.release_version = parser.release_version
          release.build_version = parser.build_version
          release.device = parser.device_type

          if parser.os == AppInfo::Platform::IOS
            release.release_type ||= parser.release_type

            icon_file = parser.icons.last.try(:[], :uncrushed_file) || parser.icons.last.try(:[], :file)
            release.icon = icon_file if icon_file
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

            parser.devices.each do |udid|
              release.devices << Device.find_or_create_by(udid: udid)
            end
          end
        rescue AppInfo::UnkownFileTypeError
          release.errors.add(:file, '上传的应用无法正确识别')
        ensure
          parser.clear!
        end
      end
    end
  end

  def app_name
    "#{app.name} #{scheme.name} #{channel.name}"
  end

  def size
    file&.size
  end
  alias_method :file_size, :size

  def short_git_commit
    return nil if git_commit.blank?

    git_commit[0..8]
  end

  def changelog_list(use_default_changelog = true)
    return empty_changelog(use_default_changelog) if changelog.blank?
    return [{'message' => changelog.to_s}] unless changelog.is_a?(Array) || changelog.is_a?(Hash)

    changelog
  end

  def has_file?
    return false if file.blank?

    File.exist?(file.path)
  end

  def download_url
    download_release_url(id)
  end

  def install_url
    return download_url if channel.device_type.casecmp('android').zero?

    download_url = channel_release_install_url(channel.slug, id)
    "itms-services://?action=download-manifest&url=#{download_url}"
  end

  def release_url
    channel_release_url(channel, self)
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
    return if channel.bundle_id_matched?(self.bundle_id)

    message = "#{channel.app_name} 的 bundle id 或 packet name `#{self.bundle_id}` 无法和 `#{channel.bundle_id}` 匹配"
    errors.add(:file, message)
  end

  private

  def auto_release_version
    latest_version = Release.where(channel: channel).limit(1).order(id: :desc).last
    self.version = latest_version ? (latest_version.version + 1) : 1
  end

  def convert_changelog
    if json_string?(changelog)
      self.changelog = JSON.parse(changelog)
    elsif changelog.blank?
      self.changelog = []
    elsif changelog.is_a?(String)
      hash = []
      changelog.split("\n").each do |message|
        next if message.blank?

        hash << { message: message }
      end
      self.changelog = hash
    else
      self.changelog ||= []
    end
  end

  def convert_custom_fields
    if json_string?(custom_fields)
      self.custom_fields = JSON.parse(custom_fields)
    elsif custom_fields.blank?
      self.custom_fields = []
    else
      self.custom_fields ||= []
    end
  end

  def detect_device
    self.device ||= channel.device_type
  end

  ORIGIN_PREFIX = 'origin/'
  def trip_branch
    return if branch.blank?
    return unless branch.start_with?(ORIGIN_PREFIX)

    self.branch = branch[ORIGIN_PREFIX.length..-1]
  end

  def default_source
    self.source ||= 'API'
  end

  def json_string?(value)
    JSON.parse(value)
    true
  rescue
    false
  end

  def enabled_validate_bundle_id?
    bundle_id = channel.bundle_id
    !(bundle_id.blank? || bundle_id == '*')
  end
end
