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

    metadata.update_attribute(:user_id, @user_id) if @user_id.present?
    update_release_resouces(metadata)
    # broadcast_release_metadata
  rescue AppInfo::UnknownFormatError
    # ignore
  end

  private

  # # turbo_stream_from dom_id(release, :metadata) in view/releases/body/_metadata.html.slim
  # # TODO: not working yet, view include many devise helper methods need current_user from env of request. 
  # def broadcast_release_metadata
  #   return if @user_id.blank? || @release.blank?

  #   turbo_stream(
  #     method: :broadcast_replace_to,
  #     target: dom_id(release, :metadata), # "metadata_release_#{release_id}"
  #     partial: 'releases/body/metadata',
  #     locals: { release: release, signed_in?: true }
  #   )
  # end

  def update_release_resouces(metadata)
    return if release.blank?

    metadata.update_attribute(:release_id, release.id)
    release.update(release_type: metadata.release_type) if release.release_type.blank?
  end

  def determine_file!
    file = release&.file.file
    unless file && File.exist?(file.path)
      logger.error('File was not found, it had been clean or deleted')
      return
    end

    file
  end

  def release
    @release ||= Release.find(@release_id)
  end
end
