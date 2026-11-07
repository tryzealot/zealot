# frozen_string_literal: true

class DebugFileTeardownService
  class BundleIdNotMatched < StandardError
    attr_reader :bundle_ids

    def initialize(bundle_ids)
      @bundle_ids = Array(bundle_ids)
      super(@bundle_ids.join(', '))
    end
  end

  attr_reader :debug_file, :error_message

  def initialize(debug_file)
    @debug_file = debug_file.is_a?(DebugFile) ? debug_file : DebugFile.find_by(id: debug_file)
    @error_message = nil
  end

  def call
    return false unless @debug_file && @debug_file.file?

    @debug_file.update_column(:parse_error, nil)

    parser = AppInfo.parse(@debug_file.file.path)
    case parser.format
    when AppInfo::Format::DSYM
      parse_dsym(parser)
    when AppInfo::Format::PROGUARD
      parse_proguard(parser)
    else
      raise AppInfo::UnknownFormatError
    end

    true
  rescue AppInfo::NotFoundError
    fail_with(I18n.t('active_job.debug_file.failures.not_found_file'))
  rescue AppInfo::UnknownFormatError
    fail_with(I18n.t('active_job.debug_file.failures.unknown_format'))
  rescue BundleIdNotMatched => e
    fail_with(I18n.t('active_job.debug_file.failures.not_matched_bundle_id', bundle_id: e.message))
  rescue StandardError => e
    Rails.logger.error("[DebugFileTeardownService] debug file #{@debug_file.id} failed: #{e.class}: #{e.message}")
    fail_with(I18n.t('active_job.debug_file.failures.unknown_parse', message: e.message))
  ensure
    parser&.clear!
  end

  def success?
    @error_message.blank?
  end

  private

  def fail_with(message)
    @error_message = message
    @debug_file.update_column(:parse_error, message)
    false
  end

  def parse_dsym(parser)
    bundle_ids = @debug_file.app.bundle_ids

    if bundle_ids.present?
      upload_bundle_ids = []
      matched_object = nil
      parser.objects.each do |object|
        upload_bundle_ids << object.bundle_id
        if bundle_ids.include?(object.bundle_id)
          matched_object = object
          break
        end
      end

      raise BundleIdNotMatched, upload_bundle_ids if matched_object.blank?
    else
      matched_object = parser.objects.first
    end

    if (release_version = matched_object&.release_version) &&
       (build_version = matched_object&.build_version)
      @debug_file.update!(
        release_version: release_version,
        build_version: build_version
      )
    end

    parser.objects.each do |object|
      object.machos.each do |macho|
        metadata = @debug_file.metadata.find_or_initialize_by(uuid: macho.uuid)
        metadata.size = macho.size
        metadata.type = macho.cpu_name
        metadata.object = object.object
        metadata.data = {
          main: object.identifier == matched_object&.identifier,
          identifier: object.identifier
        }
        metadata.save
      end
    end
  end

  def parse_proguard(parser)
    check_proguard_package_name(parser)

    if (release_version = parser.release_version) &&
       (build_version = parser.build_version)
      @debug_file.update!(
        release_version: release_version,
        build_version: build_version
      )
    end

    metadata = @debug_file.metadata.find_or_initialize_by(uuid: parser.uuid)
    metadata.object = parser&.package_name
    metadata.type = parser.format
    metadata.data = { files: files(parser) }
    metadata.save
  end

  def check_proguard_package_name(parser)
    package_names = @debug_file.app.package_names
    package_name = parser.package_name

    return if package_names.blank? || package_name.blank?
    return if package_names.include?(package_name)

    raise BundleIdNotMatched, package_name
  end

  def files(parser)
    return [] unless parser.contents && Dir.exist?(parser.contents)

    Dir.glob(File.join(parser.contents, '*')).map do |path|
      file_stat(path)
    end
  end

  def file_stat(path)
    {
      name: File.basename(path),
      size: File.size(path)
    }
  end
end
