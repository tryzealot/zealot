# frozen_string_literal: true

class Release < ApplicationRecord
  extend ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TranslationHelper
  include ReleaseUrl
  include ReleaseAuth

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  scope :latest, -> { order(version: :desc).first }

  belongs_to :channel
  has_one :metadata, class_name: 'Metadatum', dependent: :destroy
  has_and_belongs_to_many :devices, dependent: :destroy

  validates :file, presence: true
  validate :bundle_id_matched, on: :create

  before_create :auto_release_version
  before_create :default_source
  before_create :detect_device
  before_save   :convert_changelog
  before_save   :convert_custom_fields
  before_save   :strip_branch

  delegate :scheme, to: :channel
  delegate :app, to: :scheme

  paginates_per     20
  max_paginates_per 50

  def self.version_by_channel(channel_slug, release_id)
    channel = Channel.friendly.find(channel_slug)
    channel.releases.find(release_id)
  end

  # 上传 app
  def self.upload_file(params, parser = nil, default_source = 'web')
    file = params[:file]&.path
    return add_not_found_file_error if file.blank?

    create(params) do |release|
      rescuing_app_parse_errors do
        parser ||= AppInfo.parse(file)
        build_metadata(release, parser, default_source)

        # iOS 且是 AdHoc 尝试解析 UDID 列表
        if parser.os == AppInfo::Platform::IOS &&
            parser.release_type == AppInfo::IPA::ExportType::ADHOC &&
            parser.devices.present?

          parser.devices.each do |udid|
            release.devices << Device.find_or_create_by(udid: udid)
          end
        end
      ensure
        parser&.clear!
      end
    end
  end

  def self.add_not_found_file_error
    release = Release.new
    release.errors.add(:file, :invalid)
    release
  end
  private_methods :add_not_found_file_error

  def self.build_metadata(release, parser, default_source)
    release.source ||= default_source
    release.name = parser.name
    release.bundle_id = parser.bundle_id
    release.release_version = parser.release_version
    release.build_version = parser.build_version
    release.device_type = parser.device_type
    release.release_type ||= parser.release_type if parser.respond_to?(:release_type)

    icon_file = fetch_icon(parser)
    release.icon = icon_file if icon_file
  end
  private_methods :build_metadata

  def self.fetch_icon(parser)
    file = case parser.os
           when AppInfo::Platform::IOS
             parser.icons.last.try(:[], :uncrushed_file)
           when AppInfo::Platform::MACOS
             return if parser.icons.blank?

             parser.icons[:sets].last.try(:[], :file)
           when AppInfo::Platform::ANDROID
             # 处理 Android anydpi 自适应图标
             parser.icons
                   .reject { |f| File.extname(f[:file]) == '.xml' }
                   .last
                   .try(:[], :file)
           end


    File.open(file, 'rb') if file
  end
  private_methods :fetch_icon

  def self.rescuing_app_parse_errors
    yield
  rescue AppInfo::UnkownFileTypeError, NoMethodError => e
  #   raise AppInfo::UnkownFileTypeError, t('teardowns.messages.errors.not_support_file_type')
  logger.error e.full_message
  # rescue NoMethodError => e
  #   logger.error e.full_message
  #   Sentry.capture_exception e
  #   raise AppInfo::Error, t('teardowns.messages.errors.failed_get_metadata')
  # rescue => e
  #   logger.error e.full_message
  #   Sentry.capture_exception e
  #   raise AppInfo::Error, t('teardowns.messages.errors.unknown_parse', class: e.class, message: e.message)
  end
  private_methods :rescuing_app_parse_errors

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

  def array_changelog(use_default_changelog = true)
    return empty_changelog(use_default_changelog) if changelog.blank?
    return [{'message' => changelog.to_s}] unless changelog.is_a?(Array) || changelog.is_a?(Hash)

    changelog
  end

  def text_changelog(use_default_changelog = true)
    array_changelog(use_default_changelog).each_with_object([]) do |line, obj|
      obj << "- #{line['message']}"
    end.join("\n")
  end

  def file?
    return false if file.blank?

    File.exist?(file.path)
  end

  def file_extname
    return '.zip' if file.blank? || !File.file?(file&.path)

    File.extname(file.path)
  end

  def download_filename
    [
      channel.slug, release_version, build_version, created_at.strftime('%Y%m%d%H%M')
    ].join('_') + file_extname
  end

  def empty_changelog(use_default_changelog = true)
    return [] unless use_default_changelog

    @empty_changelog ||= [{
      'message' => t('releases.messages.default_changelog')
    }]
  end

  def outdated?
    lastest = channel.releases.last

    return lastest if lastest.id > id
  end

  def bundle_id_matched
    return if file.blank? || channel&.bundle_id.blank?
    return if channel.bundle_id_matched?(self.bundle_id)

    message = t('releases.messages.errors.bundle_id_not_matched', got: self.bundle_id,
                                                                  expect: channel.bundle_id)
    errors.add(:file, message)
  end

  def perform_teardown_job(user_id)
    TeardownJob.perform_later(id, user_id)
  end

  def platform
    if ios?
      'iOS'
    elsif android?
      'Android'
    elsif mac?
      'macOS'
    else
      'Unknown'
    end
  end

  def ios?
    platform_type.casecmp?('ios') || platform_type.casecmp?('iphone') ||
    platform_type.casecmp?('ipad') || platform_type.casecmp?('universal')
  end

  def android?
    platform_type.casecmp?('android') || platform_type.casecmp?('phone') ||
    platform_type.casecmp?('tablet') || platform_type.casecmp?('watch') ||
    platform_type.casecmp?('television') || platform_type.casecmp?('automotive')
  end

  def mac?
    platform_type.casecmp?('macos')
  end

  private

  def platform_type
    @platform_type ||= (device_type || channel.device_type)
  end

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
    self.device_type ||= channel.device_type
  end

  ORIGIN_PREFIX = 'origin/'
  def strip_branch
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
