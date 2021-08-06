# frozen_string_literal: true

class TeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(release_id, user_id)
    return unless file = determine_file!(release_id)

    metadata = TeardownService.call(file.path)
    metadata.update_attribute(:user_id, user_id) if user_id.present?
    update_release_resouces(release_id, metadata)
  end

  private

  def update_release_resouces(release_id, metadata)
    return if release_id.blank?

    metadata.update_attribute(:release_id, release_id)
    release = release(id: release_id)
    release.update(release_type: metadata.release_type)
  end

  def determine_file!(release_id)
    release = release(id: release_id)
    file = release&.file.file
    unless file && File.exist?(file.path)
      logger.error('文件已经无法找到，可能已经被清理或删除')
      return
    end

    file
  end

  def release(id: release_id)
    @release ||= Release.find(id)
  end
end
