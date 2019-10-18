class ApplicationMailer < ActionMailer::Base
  default from: ENV['ACTION_MAILER_DEFAULT_FROM']
  layout 'mailer'
end
