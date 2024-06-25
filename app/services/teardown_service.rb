# frozen_string_literal: true

class TeardownService
  include ActionView::Helpers::TranslationHelper

  attr_reader :file

  def initialize(file)
    @file = file
  end

  def call
    file_type = AppInfo.file_type(file)
    return if file_type == AppInfo::Format::UNKNOWN

    process
  end

  private

  def process
    checksum = checksum(file)
    metadata = Metadatum.find_or_initialize_by(checksum: checksum)

    parser = AppInfo.parse(file)
    if parser.format == AppInfo::Format::MOBILEPROVISION
      metadata.name = parser.app_name
      metadata.platform = :mobileprovision
      metadata.device = parser.platform
      metadata.release_type = parser.type
      metadata.size = File.size(file)

      process_mobileprovision(parser, metadata)
    else
      case parser.platform
      when AppInfo::Platform::IOS, AppInfo::Platform::APPLETV
        process_ios(parser, metadata)
      when AppInfo::Platform::ANDROID
        process_android(parser, metadata)
      when AppInfo::Platform::MACOS
        process_macos(parser, metadata)
      when AppInfo::Platform::WINDOWS
        process_windows(parser, metadata)
      end
      parser.clear!
    end

    metadata.save!(validate: false)
    metadata
  end

  def process_app_common(parser, metadata)
    metadata.name = parser.name
    metadata.platform = parser.platform
    metadata.device = parser.device
    metadata.release_version = parser.release_version
    metadata.build_version = parser.build_version
    metadata.size = parser.size
    if parser.platform != AppInfo::Platform::WINDOWS
      metadata.min_sdk_version = parser.respond_to?(:min_os_version) ? parser.min_os_version : parser.min_sdk_version
    end
  end

  ###########
  # Android #
  ###########

  def process_android(parser, metadata)
    process_app_common(parser, metadata)

    metadata.bundle_id = parser.package_name
    metadata.target_sdk_version = parser.target_sdk_version
    metadata.activities = parser&.activities&.select(&:present?).map(&:name)
    metadata.permissions = parser&.use_permissions&.select(&:present?) || []
    metadata.features = parser&.use_features&.select(&:present?) || []
    metadata.services = parser&.services&.sort_by(&:name)&.select(&:present?)&.map(&:name) || []
    metadata.url_schemes = parser&.schemes&.sort
    metadata.deep_links = parser&.deep_links&.sort

    process_signature_certs(parser, metadata)
  end

  def process_signature_certs(parser, metadata)
    metadata.developer_certs = parser.signatures.each_with_object([]) do |sign, certs|
      signature = { scheme: sign[:version] }
      signature[:verified] = sign[:verified]
      signature[:certificates] = sign[:certificates]&.each_with_object([]) do |cert, obj|
        data = {
          version: cert.version,
          serial: {
            number: cert.serial,
            hex: cert.serial(16, prefix: '0x'),
          },
          format: cert.format,
          digest: cert.digest,
          algorithem: cert.algorithm,
          subject: cert.subject(format: :to_a),
          issuer: cert.issuer(format: :to_a),
          created_at: cert.created_at,
          expired_at: cert.expired_at,
          fingerprint: {
            md5: cert.fingerprint(:md5, delimiter: ':'),
            sha1: cert.fingerprint(:sha1, delimiter: ':'),
            sha256: cert.fingerprint(:sha256, delimiter: ':'),
          }
        }
        data[:length] = begin
                          cert.size
                        rescue NotImplementedError
                          nil
                        end

        obj << data
      end

      certs << signature
    end
  end

  ###############
  # iOS/AppleTV #
  ###############

  def process_ios(parser, metadata)
    process_app_common(parser, metadata)
    process_mobileprovision(parser.mobileprovision, metadata) if parser.mobileprovision?

    metadata.bundle_id = parser.bundle_id
    metadata.release_type = parser.release_type

    if parser.release_type == AppInfo::IPA::ExportType::ADHOC && (devices = parser.devices)
      metadata.devices = devices
    end

    if url_schemes = parser.url_schemes
      metadata.url_schemes = url_schemes.each_with_object([]) do |option, obj|
        next unless schemes = option[:schemes]

        obj << schemes.split(', ')
      end
    end
  end

  ###########
  # macOS   #
  ###########

  def process_macos(parser, metadata)
    process_app_common(parser, metadata)
    metadata.bundle_id = parser.bundle_id
    # metadata.target_sdk_version = parser.target_sdk_version
  end

  #########################
  # Provision (iOS/macOS) #
  #########################

  def process_mobileprovision(mobileprovision, metadata)
    return unless mobileprovision

    process_mobileprovision_metadata(mobileprovision, metadata)
    process_developer_certs(mobileprovision, metadata)
    process_entitlements(mobileprovision, metadata)
    process_enabled_capabilities(mobileprovision, metadata)
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
    return unless certificates = mobileprovision.certificates

    metadata.developer_certs = certificates.each_with_object([]) do |cert, obj|
      obj << {
        name: cert.subject(format: :to_a).find { |name, _,| name == 'CN' }[1].force_encoding('UTF-8'),
        version: cert.version,
        serial: {
          number: cert.serial,
          hex: cert.serial(16, prefix: '0x'),
        },
        format: cert.format,
        digest: cert.digest,
        algorithem: cert.algorithm,
        subject: cert.subject(format: :to_a),
        issuer: cert.issuer(format: :to_a),
        created_at: cert.created_at,
        expired_at: cert.expired_at,
        fingerprint: {
          md5: cert.fingerprint(:md5, delimiter: ':'),
          sha1: cert.fingerprint(:sha1, delimiter: ':'),
          sha256: cert.fingerprint(:sha256, delimiter: ':'),
        }
      }
    end
  end

  def process_entitlements(mobileprovision, metadata)
    return unless entitlements = mobileprovision.Entitlements

    metadata.entitlements = entitlements.sort.each_with_object({}) do |ent, obj|
      key, value = ent
      obj[key] = value
    end
  end

  def process_enabled_capabilities(mobileprovision, metadata)
    return unless capabilities = mobileprovision.enabled_capabilities

    metadata.capabilities = capabilities.sort
  end

  #########################
  # Windws                #
  #########################

  def process_windows(parser, metadata)
    process_app_common(parser, metadata)
    process_imports(parser, metadata)

    metadata.mobileprovision = {
      archs: parser.archs,
      company_name: parser.company_name,
      file_version: parser.file_version,
      product_name: parser.product_name,
      file_description: parser.file_description,
      copyright: parser.copyright,
      assembly_version: parser.assembly_version,
      original_filename: parser.original_filename,
      binary_size: parser.binary_size
    }
  end

  def process_imports(parser, metadata)
    return unless imports = parser.imports

    metadata.entitlements = imports.sort.each_with_object({}) do |ent, obj|
      key, value = ent
      obj[key] = value
    end
  end

  def checksum(file)
    @checksum ||= lambda {
      require 'digest'

      checksum = Digest::SHA1.hexdigest(File.read(file))
      checksum = checksum.encode('UTF-8') if checksum.respond_to?(:encode)
      checksum
    }.call
  end
end
