class UserMailer < ApplicationMailer
  def activation_email(user)
    @user = user
    @url = active_user_url(@user.activation_token)
    mail(to: @user.email, subject: '激活 Zealot 系统账户')
  end
end
