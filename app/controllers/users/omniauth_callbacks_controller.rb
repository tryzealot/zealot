class Users::OmniauthCallbacksController < ApplicationController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      flash[:success] = 'Logined with Google Account'
      sign_in_and_redirect @user #, event: :authentication # this will throw if @user is not activated
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def passthru
  end

  def failure
    flash[:error] = 'Failure to login' # if using sinatra-flash or rack-flash
    redirect_to root_path
  end
end
