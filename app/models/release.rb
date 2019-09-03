class Release < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  belongs_to :channel

  validates :bundle_id, :release_version, :build_version, :file, presence: true

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

  def self.latest
    order(version: :desc).first
  end

  def scheme
    channel.scheme
  end

  def app
    scheme.app
  end

  def app_name
    "#{app.name} #{channel.name} #{scheme.name}"
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
end
