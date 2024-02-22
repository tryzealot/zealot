# frozen_string_literal: true

class Release < ApplicationRecord
  extend ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TranslationHelper
  include ReleaseUrl
  include ReleaseAuth
  include ReleaseParser

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  scope :latest, -> { order(version: :desc).first }

  belongs_to :channel
  has_one :metadata, class_name: 'Metadatum', dependent: :destroy
  has_and_belongs_to_many :devices, dependent: :destroy

  validates :file, presence: true
  validate :bundle_id_matched, on: :create
  validate :determine_file_exist
  validate :determine_disk_space

  before_create :auto_release_version
  before_create :default_source
  before_create :detect_device
  before_save   :convert_changelog
  before_save   :convert_custom_fields
  before_save   :strip_branch

  delegate :scheme, to: :channel
  delegate :app, to: :scheme

  paginates_per     50
  max_paginates_per 100

  def self.version_by_channel(channel_slug, release_id)
    channel = Channel.friendly.find(channel_slug)
    channel.releases.find(release_id)
  end

  # 上传 app
  def self.upload_file(params, parser = nil, default_source = 'web')
    Release.new(params) do |release|
      release.parse!(parser, default_source)
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

  def array_changelog(default_template: true)
    return empty_changelog(default_template) if changelog.blank?
    return [{'message' => changelog.to_s}] unless changelog.is_a?(Array) || changelog.is_a?(Hash)

    changelog
  end

  def text_changelog(default_template: true, head_line: false, field: 'message')
    array_changelog(default_template: default_template).each_with_object([]) do |line, obj|
      message = head_line ? line[field].split("\n")[0] : line[field]
      obj << "- #{message}"
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
    elsif windows?
      'Windows'
    elsif linux?
      'Linux'
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

  def windows?
    platform_type.casecmp?('windows')
  end

  def linux?
    platform_type.casecmp?('linux') || platform_type.casecmp?('rpm') ||
    platform_type.casecmp?('deb')
  end

  # @return [Boolean, nil] expired true or false in get expoired_at, nil is unknown.
  def cert_expired?
    return unless ios?
    return unless expired_date = metadata&.mobileprovision&.fetch('expired_at', nil)

    (Time.parse(expired_date) - Time.now) <= 0
  end

  def debug_file
    debug_files = DebugFile.where(app: app, release_version: release_version, build_version: build_version)
    return if debug_files.blank?

    debug_files.select do |debug_file|
      if ios?
        debug_file.metadata.where("data->>'identifier' = ?", bundle_id).count > 0
      elsif android?
        debug_file.metadata.where(object: bundle_id).count > 0
      end
    end.first
  end

  private

  def platform_type
    @platform_type ||= (device_type || Channel.device_types[channel.device_type])
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

        message = message[1..-1].strip if message.start_with?('-')
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
    self.device_type ||= Channel.device_types[channel.device_type]
  end

  def determine_file_exist
    if self.file&.path.blank?
      errors.add(:file, :invalid)
    end
  end

  def determine_disk_space
    upload_path = Sys::Filesystem.stat(Rails.root.join('public/uploads'))

    # Combo Orginal file and unarchived files
    if upload_path.bytes_free < (self&.file&.size || 0) * 3
      errors.add(:file, :not_enough_space)
    end
  rescue
    # do nothing
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
