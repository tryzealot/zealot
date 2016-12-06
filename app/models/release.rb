class Release < ActiveRecord::Base
  mount_uploader :file, AppFileUploader
  mount_uploader :icon, AppIconUploader

  belongs_to :app

  before_create :auto_release_version
  before_create :auto_file_size

  def self.latest
    order(version: :desc).first
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

  private

  def auto_release_version
    latest_version = Release.where(app_id: app_id).last
    self.version = latest_version ? (latest_version.version + 1) : 1
  end

  def auto_file_size
    self.filesize = file.size if file.present? && file_changed?
  end
end
