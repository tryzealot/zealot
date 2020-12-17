# frozen_string_literal: true

class TeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(release_id, user_id = nil)
    release = Release.find(release_id)
    file = release&.file.file
    unless file && File.exist?(file.path)
      logger.error('文件已经无法找到，可能已经被清理或删除')
      return
    end

    metadata = TeardownService.call(file.path)
    metadata.update_attribute(:release_id, release_id) if release_id.present?
    metadata.update_attribute(:user_id, user_id) if user_id.present?
  end
end
