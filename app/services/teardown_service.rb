# frozen_string_literal: true

class TeardownService < ApplicationService
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def call
    file_type = AppInfo.file_type(file)
    unless file_type == :ipa || file_type == :apk
      # FIXME: 处理未知文件类型
      puts "Can not process file: #{file}, file type: #{file_type}"
    end

    process
  end

  private

  def process
    checksum = checksum(file)
    metadata = Metadatum.find_or_initialize_by(checksum: checksum)
    return metadata unless metadata.new_record?

    parser = AppInfo.parse(file)
    case parser.os
    when AppInfo::Platform::IOS
      process_ios(parser, metadata)
    when AppInfo::Platform::ANDROID
      process_android(parser, metadata)
    end

    metadata.save!(validate: false)
    metadata
  end

  def process_android(parser, metadata)
    process_app_common(parser, metadata)

    metadata.bundle_id = parser.package_name
    metadata.target_sdk_version = parser.target_sdk_version
    metadata.activities = parser.activities.select(&:present?).map(&:name) if parser.activities.present?
    metadata.permissions = parser.use_permissions.select(&:present?) if parser.use_permissions.present?
    metadata.features = parser.use_features.select(&:present?) if parser.use_features.present?
    metadata.services = parser.services.sort_by(&:name).select(&:present?).map(&:name) if parser.services.present?
  end

  def process_ios(parser, metadata)
    process_app_common(parser, metadata)
    process_mobileprovision(parser, metadata)

    metadata.bundle_id = parser.bundle_id
    metadata.release_type = parser.release_type

    if parser.release_type == AppInfo::IPA::ExportType::ADHOC && (devices = parser.devices)
      metadata.devices = devices
    end

    if schemes = parser.info['CFBundleURLTypes']
      metadata.url_schemes = schemes.each_with_object([]) do |value, obj|
        obj << value['CFBundleURLSchemes'].split(', ')
      end
    end
  end

  def process_app_common(parser, metadata)
    metadata.name = parser.name
    metadata.platform = parser.os.downcase
    metadata.device = parser.device_type
    metadata.release_version = parser.release_version
    metadata.build_version = parser.build_version
    metadata.size = parser.size
    metadata.min_sdk_version = parser.min_sdk_version
  end

  def process_mobileprovision(parser, metadata)
    return unless parser.mobileprovision?

    process_mobileprovision_metadata(parser, metadata)
    process_developer_certs(parser, metadata)
    process_entitlements(parser, metadata)
    process_entitlements(parser, metadata)
  end

  def process_mobileprovision_metadata(parser, metadata)
    metadata.mobileprovision = {
      uuid: parser.mobileprovision.UUID,
      profile_name: parser.profile_name,
      team_identifier: parser.team_identifier,
      release_type: parser.release_type,
      team_name: parser.team_name,
      created_at: parser.mobileprovision.created_date,
      expired_at: parser.expired_date
    }
  end

  def process_developer_certs(parser, metadata)
    if developer_certs = parser.mobileprovision.developer_certs
      metadata.developer_certs = developer_certs.each_with_object([]) do |cert, obj|
        obj << {
          name: cert.name,
          created_at: cert.created_date,
          expired_at: cert.expired_date
        }
      end
    end
  end

  def process_entitlements(parser, metadata)
    if entitlements = parser.mobileprovision.Entitlements
      metadata.entitlements = entitlements.sort.each_with_object({}) do |e, obj|
        key, value = e

        obj[key] = value
      end
    end
  end

  def process_entitlements(parser, metadata)
    if capabilities = parser.mobileprovision.enabled_capabilities
      metadata.capabilities = capabilities.sort
    end
  end

  def checksum(file)
    @checksum ||= begin
      require 'digest'
      checksum = Digest::SHA1.hexdigest(File.read(file))
      checksum = checksum.encode('UTF-8') if checksum.respond_to?(:encode)
      checksum
    end
  end
end