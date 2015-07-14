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
      "public/uploads/apps",
      app.user.id.to_s,
      app_id.to_s,
      "#{id.to_s}#{file_ext}"
    )
  end

  def filename
    created_at.strftime('%Y%m%d%H%M') + '_' + app.slug + file_ext
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
