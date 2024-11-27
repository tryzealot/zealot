# frozen_string_literal: true

module ReleaseParser
  extend ActiveSupport::Concern

  def parse!(parser, default_source)
    parse_app(parser, default_source)

    self
  end

  private

  def parse_app(parser, default_source)
    parser ||= AppInfo.parse(self.file.path)
    build_metadata(parser, default_source)
    relates_to_devices(parser)
  rescue AppInfo::UnknownFormatError
    # ignore
  rescue => e
    logger.error e.full_message
  ensure
    parser&.clear!
  end

  def build_metadata(parser, default_source)
    # iOS, Android only
    self.name ||= parser.name
    self.bundle_id = parser.bundle_id if parser.respond_to?(:bundle_id)
    self.source ||= default_source
    self.device_type = parser.device
    self.release_version = parser.release_version
    self.build_version = parser.build_version
    self.release_type ||= parser.release_type if parser.respond_to?(:release_type)

    icon_file = fetch_icon(parser)
    self.icon = icon_file if icon_file
  end

  def relates_to_devices(parser)
    # iOS 且是 AdHoc 尝试解析 UDID 列表
    if parser.platform == AppInfo::Platform::IOS &&
       parser.release_type == AppInfo::IPA::ExportType::ADHOC && \
       parser.devices.present?

      parser.devices.each do |udid|
        self.devices.find_or_initialize_by(udid: udid)
      end
    end
  end

  def fetch_icon(parser)
    file = case parser.platform
           when AppInfo::Platform::IOS
            return if parser.icons.blank?

            # NOTE: uncrushed_file may be return nil (#1196)
            biggest_icon(parser.icons, file_key: :uncrushed_file) ||
              biggest_icon(parser.icons, file_key: :file)
           when AppInfo::Platform::MACOS
             return if parser.icons.blank?

             biggest_icon(parser.icons[:sets])
           when AppInfo::Platform::ANDROID
            return if parser.icons.blank?

            biggest_icon(parser.icons(exclude: :xml))
           when AppInfo::Platform::WINDOWS
             return if parser.icons.blank?

             biggest_icon(parser.icons)
           when AppInfo::Platform::HARMONYOS
             return if parser.icons.blank?

             biggest_icon(parser.icons)
           end

    File.open(file, 'rb') if file
  end

  def biggest_icon(icons, file_key: :file)
    return if icons.blank?

    icons.max_by { |icon| icon[:dimensions][0] }
         .try(:[], file_key)
  end
end
