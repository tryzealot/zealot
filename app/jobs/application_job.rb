# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper

  retry_on StandardError, wait: :exponentially_longer, attempts: Float::INFINITY

  # TODO: remove sidekiq legacy code.
  # include ActiveJob::Status

  protected

  def logger
    @logger ||= GoodJob.logger
  end

  def notificate_success(**options)
    notification_user(**options.merge(status: 'success'))
  end

  def notificate_failure(**options)
    notification_user(**options.merge(status: 'failure'))
  end

  def notification_user(type:, status:, message:, user_id:, **options)
    return if user_id.blank?

    bordcast_key = "notification:#{user_id}"
    ActionCable.server.broadcast(bordcast_key, options.merge(
      type: type,
      status: status,
      message: message
    ))
  end
end
