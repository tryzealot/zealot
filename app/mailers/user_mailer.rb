class UserMailer < ApplicationMailer
  default from: '"QMobile 通知" <no-reply@2b6.me>'
  default
  def activation_email(user)
    @user = user
    @url = active_user_url(@user.activation_token)
    mail(to: @user.email, subject: '激活 QMobile 系统账户')
  end
end
