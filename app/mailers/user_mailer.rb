class UserMailer < ApplicationMailer
  default from: 'notifications@2b6.me'

  def activation_email(user)
    @user = user
    @url = new_user_session_url
    mail(to: @user.email, subject: '激活 QMobile 系统账户')
  end
end
