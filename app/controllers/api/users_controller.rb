# frozen_string_literal: true

class Api::UsersController < Api::BaseController
  before_action :validate_user_token
  before_action :set_user, only: %i[show update destroy]

  # GET /api/users
  def index
    @users = User.all
    authorize @users

    render json: @users
  end

  # GET /api/users/:id
  def show
    render json: @user
  end

  # GET /api/users/me
  def me
    render json: current_user
  end

  # GET /api/users/search
  def search
    email = params[:email]
    raise Zealot::Error::RecordNotFound.new(model: User) if email.blank?

    @user = User.find_by!(email: email)
    authorize @user

    render json: @user
  end

  # POST /api/users
  def create
    @user = User.create!(user_params)
    authorize @user

    render json: @user
  end

  # PUT /api/users/:id
  def update
    @user.update!(user_params)
    render json: @user
  end

  # DELETE /api/users/:id
  def destroy
    @user.destroy!
    render json: { mesage: 'OK' }
  end

  protected

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    @user_params ||= params.permit(:username, :email, :password, :role)
  end
end
