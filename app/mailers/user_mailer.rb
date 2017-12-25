class UserMailer < ApplicationMailer
  default from: '"QMobile 通知" <no-reply@2b6.me>'
  default
  def activation_email(user)
    @user = user
    @url = new_user_session_url
    mail(to: @user.email, subject: '激活 QMobile 系统账户')
  end
end
