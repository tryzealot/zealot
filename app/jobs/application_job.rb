# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include ActiveJob::Status
  include ActionView::Helpers::TranslationHelper

  protected

  def logger
    @logger ||= Sidekiq.logger
  end

  def notification_user(type:, status:, user_id:, message:)
      ActionCable.server.broadcast "notification:#{user_id}", {
        type: type,
        status: status,
        html: "<div class='alert alert-success alert-block text-center'>
                <i class='fa fa-circle-o-notch fa-spin'></i>
                #{t('web_hooks.messages.done')}
              </div>"
    }
  end
end
