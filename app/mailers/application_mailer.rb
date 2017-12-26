class ApplicationMailer < ActionMailer::Base
  default from: '"QMobile" <no-reply@2b6.me>', reply_to: '"三火" <shen.wang@qyer.com>'

  layout 'mailer'
end

