class Users::ActivationsController < ApplicationController
  before_action :verify_user

  def show
  end

  private

  def verify_user
    @user = User.find_by!(activation_token: params[:token])
  end
end
