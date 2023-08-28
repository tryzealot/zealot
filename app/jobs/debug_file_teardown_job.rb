# frozen_string_literal: true

class DebugFileTeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(debug_file, user_id = nil)
    parser = AppInfo.parse(debug_file.file.path)

    case parser.format
    when AppInfo::Format::DSYM
      parse_dsym(debug_file, parser)
    when AppInfo::Format::PROGUARD
      parse_proguard(debug_file, parser)
    end

    notificate_success(
      user_id: user_id,
      type: 'teardown',
      refresh_page: true,
      message: t('active_job.debug_file.success', id: debug_file.id)
    )

  rescue AppInfo::NotFoundError
    sleep 3
    notificate_failure(
      user_id: user_id,
      type: 'teardown',
      message: t('active_job.debug_file.failures.not_found_file', id: debug_file.id)
    )
  rescue AppInfo::UnknownFormatError
    sleep 3
    debug_file.destroy
    notificate_failure(
      user_id: user_id,
      type: 'teardown',
      message: t('active_job.debug_file.failures.unknown_format')
    )
  rescue RuntimeError => e
    sleep 3
    debug_file.destroy
    notificate_failure(
      user_id: user_id,
      type: 'teardown',
      message: t('active_job.debug_file.failures.not_matched_bundle_id', bundle_id: e.message)
    )
  ensure
    parser&.clear!
  end

  private

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

      raise upload_bundle_ids.join(', ') if matched_object.blank?
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
