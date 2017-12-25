class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @title = '用户管理'
    @users = User.all
  end

  def show
    @roles = Role.all
    redirect_to :back, alert: 'Access denied.' unless @user == current_user || @user.role?(:admin)
  end

  def edit
  end

  def update

  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name, :email, :current_password, :password, :password_confirmation, :roles
    )
  end
end
