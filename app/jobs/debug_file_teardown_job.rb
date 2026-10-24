# frozen_string_literal: true

class DebugFileTeardownJob < ApplicationJob
  queue_as :app_parse

  # Raised when the uploaded dSYM or Proguard mapping file belongs to another
  # app. The identifiers found in the file are kept so the failure message can
  # tell the user what was uploaded.
  class BundleIdNotMatched < StandardError
    attr_reader :bundle_ids

    def initialize(bundle_ids)
      @bundle_ids = Array(bundle_ids)
      super(@bundle_ids.join(', '))
    end
  end

  def perform(debug_file, user_id = nil)
    failure = parse_debug_file(debug_file)
    return mark_failed(debug_file, user_id, failure) if failure

    notificate_success(
      user_id: user_id,
      type: 'teardown',
      refresh_page: true,
      message: t('active_job.debug_file.success', id: debug_file.id)
    )
    broadcast_row(debug_file)
  end

  private

  # Returns nil when the file was parsed, or the reason it could not be.
  def parse_debug_file(debug_file)
    debug_file.update_column(:parse_error, nil)

    parser = AppInfo.parse(debug_file.file.path)

    case parser.format
    when AppInfo::Format::DSYM
      parse_dsym(debug_file, parser)
    when AppInfo::Format::PROGUARD
      parse_proguard(debug_file, parser)
    else
      # A readable archive that is not a dSYM/Proguard file (an .ipa for
      # instance) has nothing to parse.
      raise AppInfo::UnknownFormatError
    end
  rescue AppInfo::NotFoundError
    t('active_job.debug_file.failures.not_found_file')
  rescue AppInfo::UnknownFormatError
    t('active_job.debug_file.failures.unknown_format')
  rescue BundleIdNotMatched => e
    t('active_job.debug_file.failures.not_matched_bundle_id', bundle_id: e.message)
  rescue StandardError => e
    logger.error("[DebugFileTeardownJob] debug file #{debug_file.id} failed: #{e.class}: #{e.message}")
    t('active_job.debug_file.failures.unknown_parse', message: e.message)
  ensure
    parser&.clear!
  end

  # Keep the upload around with the reason attached: the page then reports the
  # failure instead of waiting for a parsing that will never finish.
  def mark_failed(debug_file, user_id, message)
    sleep 3

    debug_file.update_column(:parse_error, message)
    notificate_failure(user_id: user_id, type: 'teardown', message: message)
    broadcast_row(debug_file)
  end

  # Replace the row on the app debug files page so a finished (or broken) parse
  # no longer stays "processing" until the visitor reloads.
  def broadcast_row(debug_file)
    app = debug_file.app

    Turbo::StreamsChannel.broadcast_replace_to(
      [app, :debug_files],
      target: dom_id(debug_file),
      partial: 'debug_files/debug_file',
      locals: { debug_file: debug_file, app: app }
    )
  end

  def parse_dsym(debug_file, parser)
    bundle_ids = debug_file.app.bundle_ids

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

    if (release_version = matched_object.release_version) &&
      (build_version = matched_object.build_version)
      debug_file.update!(
        release_version: release_version,
        build_version: build_version
      )
    end

    # Relates all dSYM symbols to metadata of debug file.
    parser.objects.each do |object|
      object.machos.each do |macho|
        metadata = debug_file.metadata.find_or_initialize_by(uuid: macho.uuid)
        metadata.size = macho.size
        metadata.type = macho.cpu_name
        metadata.object = object.object
        metadata.data = {
          main: object.identifier == matched_object&.identifier,
          identifier: object.identifier,
        }
        metadata.save
      end
    end
  end

  def parse_proguard(debug_file, parser)
    check_proguard_package_name(debug_file, parser)

    if (release_version = parser.release_version) &&
      (build_version = parser.build_version)
      debug_file.update!(
        release_version: release_version,
        build_version: build_version
      )
    end

    metadata = debug_file.metadata.find_or_initialize_by(uuid: parser.uuid)
    metadata.object = parser&.package_name
    metadata.type = parser.format
    metadata.data = { files: files(parser) }
    metadata.save
  end

  # A Proguard mapping file also knows its package name, so an upload for
  # another app is rejected the same way as a foreign dSYM.
  def check_proguard_package_name(debug_file, parser)
    package_names = debug_file.app.package_names
    package_name = parser.package_name

    return if package_names.blank? || package_name.blank?
    return if package_names.include?(package_name)

    raise BundleIdNotMatched, package_name
  end

  def files(parser)
    data = []
    Dir.glob(File.join(parser.contents, '*')) do |path|
      data << file_stat(path)
    end

    data
  end

  def file_stat(path)
    {
      name: File.basename(path),
      size: File.size(path)
    }
  end
end
