class Release < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  belongs_to :app
  belongs_to :user

  validates :identifier, :release_version, :build_version, :file, :extra, presence: true

  before_create :auto_release_version
  before_create :auto_file_size

  paginates_per     20
  max_paginates_per 50

  def self.latest
    order(version: :desc).first
  end

  def install_url
    if app.device_type.casecmp('android').zero?
      api_v2_apps_download_url(app.slug, version)
    else
      'itms-services://?action=download-manifest&url=' + api_v2_apps_install_url(
        app.slug,
        version,
        protocol: Rails.env.development? ? 'http' : 'https'
      )
    end
  end

  def plain_text_changelog
    text = JSON.parse(changelog).each_with_object([]) do |item, obj|
      obj << "- #{item['message']}"
    end.join("\n")

    text.blank? ? empty_text_changelog : text
  rescue
    (changelog.blank? || changelog == '(此版本由 Jenkins 自动构建)') ? empty_text_changelog : changelog
  end

  def pure_changelog
    JSON.parse(changelog)
  rescue
    return [] if changelog.blank?

    changelog.split("\n").each_with_object([]) do |item, obj|
      next if item == '(此版本由 Jenkins 自动构建)'

      _, body = item.split('. ')
      message, date = body.split(' [')
      message = message.strip
      date = date.sub(']', '').strip

      obj << {
        'date': date,
        'message': message
      }
    end
  end

  def file_extname
    case app.device_type.downcase
    when 'iphone', 'ipad', 'ios'
      '.ipa'
    when 'android'
      '.apk'
    end
  end

  def download_filename
    [app.slug, release_version, build_version, created_at.strftime('%Y%m%d%H%M')].join('_') + file_extname
  end

  def content_type
    case app.platform
    when 'iOS'
      'application/vnd.iphone'
    when 'Android'
      'application/vnd.android.package-archive'
    end
  end

  def empty_changelog
    return @empty_changelog if @empty_changelog

    @empty_changelog = [
      {
        message: "没有更新日志的原因：\n- 开发者很懒没有留下更新日志😂\n- 有不可抗拒的因素造成日志丢失👽",
        # date: Time.now.strftime("%Y-%m-%d %H:%M:%S %z"),
      }
    ]
  end

  def empty_text_changelog
    return @empty_text_changelog if @empty_text_changelog

    @empty_text_changelog = empty_changelog.map { |v| v[:message] }.join("\n")
  end

  private

  def auto_release_version
    latest_version = Release.where(app_id: app_id).last
    self.version = latest_version ? (latest_version.version + 1) : 1
  end

  def auto_file_size
    self.filesize = file.size if file.present? && file_changed?
  end
end
