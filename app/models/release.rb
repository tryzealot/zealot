class Release < ActiveRecord::Base
  belongs_to :app

  before_create :auto_release_version

  def file_ext
    fileext = case app.device_type.downcase
    when 'iphone', 'ipad', 'ios'
      '.ipa'
    when 'android'
      '.apk'
    end
  end

  def file
    File.join(
      "/var/project/mobile/apps",
      "#{app_id.to_s}_#{id.to_s}#{file_ext}"
    )
  end

  def filename
    [app.slug, release_version, build_version, created_at.strftime('%Y%m%d%H%M')].join('_') + file_ext
  end

  def content_type
    content_type = case app.device_type.downcase
    when 'iphone', 'ipad', 'ios'
      'application/vnd.iphone'
    when 'android'
      'application/vnd.android.package-archive'
    end
  end

  private
    def auto_release_version
      latest_version = Release.where(app_id:self.app_id).last
      self.version = latest_version ? (latest_version.version + 1) : 1
    end
end
