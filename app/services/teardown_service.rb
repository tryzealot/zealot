# frozen_string_literal: true

class TeardownService < ApplicationService
  include ActionView::Helpers::TranslationHelper

  attr_reader :file

  SUPPORTED_TYPES = %i[apk aab ipa mobileprovision macos]

  def initialize(file)
    @file = file
  end

  def call
    file_type = AppInfo.file_type(file)
    unless SUPPORTED_TYPES.include?(file_type)
      raise ActionController::UnknownFormat, t('teardowns.messages.errors.not_support_file_type')
    end

    process
  end

  private

  def process
    checksum = checksum(file)
    metadata = Metadatum.find_or_initialize_by(checksum: checksum)
    return metadata unless metadata.new_record?

    parser = AppInfo.parse(file)
    if parser.respond_to?(:os)
      case parser.os
      when AppInfo::Platform::IOS
        process_ios(parser, metadata)
      when AppInfo::Platform::ANDROID
        process_android(parser, metadata)
      when AppInfo::Platform::MACOS
        process_macos(parser, metadata)
      end
      parser.clear!
    elsif parser.is_a?(AppInfo::MobileProvision)
      metadata.name = parser.app_name
      metadata.platform = :mobileprovision
      metadata.device = parser.platform
      metadata.release_type = parser.type
      metadata.size = File.size(file)

      process_mobileprovision(parser, metadata)
    end

    metadata.save!(validate: false)
    metadata
  end

  def process_android(parser, metadata)
    process_app_common(parser, metadata)

    metadata.bundle_id = parser.package_name
    metadata.target_sdk_version = parser.target_sdk_version
    metadata.activities = parser&.activities&.select(&:present?).map(&:name)
    metadata.permissions = parser&.use_permissions&.select(&:present?)
    metadata.features = parser&.use_features&.select(&:present?)
    metadata.services = parser&.services&.sort_by(&:name)&.select(&:present?)&.map(&:name)
    metadata.url_schemes = parser&.schemes&.sort
    metadata.deep_links = parser&.deep_links&.sort
  end

  def process_ios(parser, metadata)
    process_app_common(parser, metadata)
    process_mobileprovision(parser.mobileprovision, metadata) if parser.mobileprovision?

    metadata.bundle_id = parser.bundle_id
    metadata.release_type = parser.release_type

    if parser.release_type == AppInfo::IPA::ExportType::ADHOC && (devices = parser.devices)
      metadata.devices = devices
    end

    if schemes = parser.info['CFBundleURLTypes']
      metadata.url_schemes = schemes.each_with_object([]) do |value, obj|
        next unless schemes_value = value['CFBundleURLSchemes']

        obj << schemes_value.split(', ')
      end
    end
  end

  def process_macos(parser, metadata)
    process_app_common(parser, metadata)
    metadata.bundle_id = parser.bundle_id
    # metadata.target_sdk_version = parser.target_sdk_version
  end

  def process_app_common(parser, metadata)
    metadata.name = parser.name
    metadata.platform = parser.os.downcase
    metadata.device = parser.device_type
    metadata.release_version = parser.release_version
    metadata.build_version = parser.build_version
    metadata.size = parser.size
    metadata.min_sdk_version = parser.respond_to?(:min_os_version) ? parser.min_os_version : parser.min_sdk_version
  end

  def process_mobileprovision(mobileprovision, metadata)
    return unless mobileprovision

    process_mobileprovision_metadata(mobileprovision, metadata)
    process_developer_certs(mobileprovision, metadata)
    process_entitlements(mobileprovision, metadata)
    process_entitlements(mobileprovision, metadata)
  end

  def process_mobileprovision_metadata(mobileprovision, metadata)
    metadata.mobileprovision = {
      uuid: mobileprovision.UUID,
      profile_name: mobileprovision.profile_name,
      team_identifier: mobileprovision.team_identifier,
      team_name: mobileprovision.team_name,
      created_at: mobileprovision.created_date,
      expired_at: mobileprovision.expired_date
    }
  end

  def process_developer_certs(mobileprovision, metadata)
    if developer_certs = mobileprovision.developer_certs
      metadata.developer_certs = developer_certs.each_with_object([]) do |cert, obj|
        obj << {
          name: cert.name,
          created_at: cert.created_date,
          expired_at: cert.expired_date
        }
      end
    end
  end

  def process_entitlements(mobileprovision, metadata)
    if entitlements = mobileprovision.Entitlements
      metadata.entitlements = entitlements.sort.each_with_object({}) do |e, obj|
        key, value = e

        obj[key] = value
      end
    end
  end

  def process_entitlements(mobileprovision, metadata)
    if capabilities = mobileprovision.enabled_capabilities
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