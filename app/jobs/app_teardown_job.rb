class AppTeardownJob < ActiveJob::Base
  queue_as :default

  def perform(_event, release)
    @release = release
    @file = QMA::App.parse(@release)
  end

  def detect_file_type!
    case @release.app.platform
    when 'iOS'
      parse_ipa!
    when 'Android'
      parse_apk!
    else
      logger.error "Unkonwn file type with release #{@release.id}"
    end
  end

  def parse_ipa!
    
  end

  def parse_apk!
  end
end
