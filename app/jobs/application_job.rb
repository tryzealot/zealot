# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TranslationHelper
  include ActiveJob::Status

  protected

  def logger
    @logger ||= GoodJob.logger
  end

  def notificate_success(**options)
    notification_user(**options.merge(type: 'notice'))
  end

  def notificate_failure(**options)
    notification_user(**options.merge(type: 'alert'))
  end

  def notification_user(user_id:, message:, type:, **options)
    return if user_id.blank?

    user = User.find(user_id)
    targer_id = :notifications
    Turbo::StreamsChannel.broadcast_append_to(
      ActionView::RecordIdentifier.dom_id(user, targer_id),
      target: targer_id,
      html: ApplicationController.render(FlashComponent.new(message, type: type, status: status), layout: false)
    )
  end
end
