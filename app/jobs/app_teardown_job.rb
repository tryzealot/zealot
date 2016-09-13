require 'app-info'

class AppTeardownJob < ActiveJob::Base
  queue_as :default

  def perform(_event, release)
    @release = release
    @file = @release.file.path
    @app = AppInfo.parse(@file)
    @icon_file = @app.icons.try(:[], -1).try(:[], :file)

    logger.info "Processing file: #{@file}"
    processing!
  end

  def processing!
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
    @release.release_type = @app.release_type
    @release.devices = @app.devices if OS.mac?
    @release.distribution = @app.distribution_name if OS.mac?

    if icon_file_exist?
      Pngdefry.defry(@icon_file, @icon_file)
      @release.icon = File.open(@icon_file)
    end

    @release.save!
  end

  def parse_apk!
    @release.icon = File.open(@icon_file) if icon_file_exist?
    @release.save!
  end

  def icon_file_exist?
    !@icon_file.empty? && File.exist?(@icon_file)
  end
end
