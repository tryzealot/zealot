# frozen_string_literal: true

class DebugFileTeardownJob < ApplicationJob
  queue_as :app_parse

  def perform(debug_file_id, user_id = nil)
    debug_file = debug_file_id.is_a?(DebugFile) ? debug_file_id : DebugFile.find_by(id: debug_file_id)
    return unless debug_file

    service = DebugFileTeardownService.new(debug_file)
    if service.call
      notificate_success(
        user_id: user_id,
        type: 'teardown',
        refresh_page: true,
        message: t('active_job.debug_file.success', id: debug_file.id)
      )
    else
      notificate_failure(
        user_id: user_id,
        type: 'teardown',
        message: service.error_message
      )
    end

    broadcast_row(debug_file)
  end

  private

  def broadcast_row(debug_file)
    app = debug_file.app

    Turbo::StreamsChannel.broadcast_replace_to(
      [app, :debug_files],
      target: dom_id(debug_file),
      partial: 'debug_files/debug_file',
      locals: { debug_file: debug_file, app: app }
    )
  end
end
