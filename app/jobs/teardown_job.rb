# frozen_string_literal: true

class TeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(release_id, user_id)
    @release_id = release_id
    @user_id = user_id

    return unless file = determine_file!

    metadata = TeardownService.new(file.path).call
    unless metadata
      logger.error "Unable to parse metadata with release: #{@release_id}"
      return
    end

    update_release_resources(metadata)
    broadcast_release_metadata
  rescue AppInfo::UnknownFormatError
    # ignore
  end

  private

  def broadcast_release_metadata
    return if release.blank?

    user = User.find_by(id: @user_id)
    Turbo::StreamsChannel.broadcast_replace_to(
      [release, :metadata],
      target: dom_id(release, :metadata),
      partial: 'releases/body/metadata',
      locals: { release: release, current_user: user }
    )
  end

  def update_release_resources(metadata)
    return if release.blank?

    attrs = { release: release }
    attrs[:user_id] = @user_id if @user_id.present?
    metadata.update(attrs)
    release.update(release_type: metadata.release_type) if release.release_type.blank?
  end

  def determine_file!
    file = release&.file&.file
    unless file && File.exist?(file.path)
      logger.error('File was not found, it had been clean or deleted')
      return
    end

    file
  end

  def release
    @release ||= Release.find_by(id: @release_id)
  end
end
