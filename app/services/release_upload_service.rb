# frozen_string_literal: true

class ReleaseUploadService
  Result = Data.define(:success?, :release, :error, :message) do
    def self.success(release)
      new(success?: true, release: release, error: nil, message: nil)
    end

    def self.failure(error, message = nil, release: nil)
      new(success?: false, release: release, error: error, message: message)
    end
  end

  def self.call(...)
    new(...).call
  end

  def initialize(channel:, file:, user:, params: {}, parser: nil, source: 'web')
    @channel = channel
    @file = file
    @user = user
    @params = (params || {}).to_h.symbolize_keys
    @parser = parser
    @source = source
  end

  def call
    if @channel.app.archived?
      return Result.failure(:app_archived,
                            I18n.t('releases.messages.errors.upload_to_archived_app', app: @channel.app.name))
    end

    parser = resolve_parser
    if parser && @channel.bundle_id.present? && @channel.bundle_id != '*'
      unless @channel.bundle_id_matched?(parser.bundle_id)
        message = I18n.t('releases.messages.errors.bundle_id_not_matched',
                         got: parser.bundle_id, expect: @channel.bundle_id)
        return Result.failure(:bundle_id_mismatch, message)
      end
    end

    release = build_release(parser)

    ActiveRecord::Base.transaction do
      release.save!
    end

    trigger_post_upload_actions(release, parser)

    Result.success(release)
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(:validation_failed, e.record.errors.full_messages.join(', '), release: release)
  rescue => e
    Rails.logger.error("Release upload failed: #{e.message}\n#{e.backtrace.join("\n")}")
    Result.failure(:internal_error, e.message, release: release)
  ensure
    cleanup_parser(parser)
  end

  private

  def resolve_parser
    return @parser if @parser
    return nil unless @file && File.exist?(@file.path)

    AppInfo.parse(@file.path)
  rescue AppInfo::UnknownFormatError
    nil
  end

  def cleanup_parser(parser)
    parser&.clear! if parser&.respond_to?(:clear!)
  end

  def build_release(parser)
    release = @channel.releases.build(@params.except(:file))
    release.file = @file
    release.source = @source if release.source.blank?

    if parser
      release.name ||= parser.name
      release.bundle_id = parser.bundle_id if parser.respond_to?(:bundle_id)
      release.device_type = parser.device
      release.release_version = parser.release_version
      release.build_version = parser.build_version
      release.release_type = parser.release_type if release.release_type.blank? && parser.respond_to?(:release_type)

      icon_file = fetch_icon(parser)
      release.icon = icon_file if icon_file

      relates_to_devices(release, parser)
    end

    release
  end

  def relates_to_devices(release, parser)
    if parser.platform == AppInfo::Platform::IOS &&
       parser.respond_to?(:release_type) &&
       parser.release_type == AppInfo::IPA::ExportType::ADHOC &&
       parser.devices.present?

      parser.devices.each do |udid|
        release.devices.find_or_initialize_by(udid: udid)
      end
    end
  end

  def fetch_icon(parser)
    file = case parser.platform
           when AppInfo::Platform::IOS
             return if parser.icons.blank?

             biggest_icon(parser.icons, file_key: :uncrushed_file) ||
               biggest_icon(parser.icons, file_key: :file)
           when AppInfo::Platform::MACOS
             return if parser.icons.blank?

             biggest_icon(parser.icons[:sets])
           when AppInfo::Platform::ANDROID
             return if parser.icons.blank?

             biggest_icon(parser.icons(exclude: :xml))
           when AppInfo::Platform::WINDOWS, AppInfo::Platform::HARMONYOS
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

  def trigger_post_upload_actions(release, parser)
    @channel.perform_web_hook('upload_events', @user&.id)
    release.perform_teardown_job(@user&.id) if parser
  end
end
