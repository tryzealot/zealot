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

    options[:type] = type
    options[:status] = status

    target = :notifications
    html = ApplicationController.render(FlashComponent.new(message, **options), layout: false)
    turbo_stream(method: :broadcast_append_to, user_id: user_id, target: target, html: html)
  end

  def turbo_stream(method:, user_id: nil, target:, **options)
    return if user_id.blank?

    user = user_id ? User.find(user_id) : nil
    streamables = options.delete(:streamables) || target
    options[:target] = target

    Turbo::StreamsChannel.send(method.to_sym, [user, streamables].compact, **options)
  end

  # Helper to generate dom_id in jobs
  def dom_id(record, prefix = nil)
    ActionView::RecordIdentifier.dom_id(record, prefix)
  end
end
