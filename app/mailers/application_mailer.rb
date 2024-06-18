# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: -> { Setting.mailer_default_from },
          reply_to: -> { Setting.mailer_default_reply_to }

  layout 'mailer'
end
