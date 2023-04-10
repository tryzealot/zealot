# frozen_string_literal: true

class DebugFileTeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(debug_file, user_id = nil)
    parser = AppInfo.parse(debug_file.file.path)

    case parser.format
    when AppInfo::Format::DSYM
      parse_dsym(debug_file, parser)
    when AppInfo::Format::PROGUARD
      update_debug_file_version(debug_file, parser)
      parse_proguard(debug_file, parser)
    end

    notificate_success(
      user_id: user_id,
      type: 'teardown',
      refresh_page: true,
      message: t('active_job.debug_file.success', id: debug_file.id)
    )
  rescue AppInfo::NotFoundError
    notificate_failure(
      user_id: user_id,
      type: 'teardown',
      message: t('active_job.debug_file.failures.not_found_file', id: debug_file.id)
    )
  rescue RuntimeError => e
    debug_file.destroy
    notificate_failure(
      user_id: user_id,
      type: 'teardown',
      message: t('active_job.debug_file.failures.not_matched_bundl_id', bundle_id: e.message)
    )
  ensure
    parser&.clear!
  end

  private

  def parse_dsym(debug_file, parser)
    bundle_ids = debug_file.app.bundle_ids

    upload_bundle_ids = []
    matched_debug_info = nil
    parser.each_file do |debug_info|
      upload_bundle_ids << debug_info.bundle_id
      if bundle_ids.include?(debug_info.bundle_id)
        matched_debug_info = debug_info
        break
      end
    end

    raise upload_bundle_ids.join(', ') if matched_debug_info.blank?

    if (release_version = matched_debug_info.release_version) &&
      (build_version = matched_debug_info.build_version)
      debug_file.update!(
        release_version: release_version,
        build_version: build_version
      )
    end

    # Relates all dSYM symbols to metadata of debug file.
    parser.each_file do |debug_info|
      debug_info.machos.each do |macho|
        debug_file.metadata.find_or_create_by(uuid: macho.uuid) do |metadata|
          metadata.size = macho.size
          metadata.type = macho.cpu_name
          metadata.object = debug_info.object
          if debug_info == matched_debug_info
            metadata.data = {
              main_app: true
            }
          end
        end
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

    debug_file.metadata.find_or_create_by(uuid: parser.uuid) do |metadata|
      metadata.type = parser.format
      metadata.data = { files: files(parser) }
    end
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
