class ApplicationMailer < ActionMailer::Base
  default from: '"Zealot" <no-reply@zealot.com>', reply_to: '"三火" <shen.wang@qyer.com>'

  layout 'mailer'
end

