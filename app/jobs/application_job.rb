# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper
  include ActiveJob::Status

  sidekiq_options backtrace: Rails.env.development? ? true : 20

  protected

  def logger
    @logger ||= Sidekiq.logger
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
