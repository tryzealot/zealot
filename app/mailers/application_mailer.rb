class ApplicationMailer < ActionMailer::Base
  default from: '"Zealot" <no-reply@zealot.com>', reply_to: '"icyleaf" <icyleaf.cn@gmail.com>'

  layout 'mailer'
end

