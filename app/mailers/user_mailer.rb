# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def omniauth_welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: t('.subject', title: Setting.site_title))
  end
end
