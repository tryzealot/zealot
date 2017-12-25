class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = '用户管理'
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    redirect_to :back, alert: 'Access denied.' unless @user == current_user || @user.role?(:admin)
  end
end
