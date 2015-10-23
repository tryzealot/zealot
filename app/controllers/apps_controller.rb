class AppsController < ApplicationController
  before_filter :check_user_logged_in!, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @apps = current_user.apps
    authorize @apps
  end

  def new
    @title = "新建应用"
    @app = App.new
  end

  def create
    @app = App.new(app_params)

    respond_to do |format|
      if @app.save
        format.html { redirect_to apps_path, notice: 'App was successfully created.' }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @app = App.find_by(slug: params[:slug])
    fail ActionController::RoutingError.new('这里没有你找的东西') unless @app
  end

  def update
    @app = App.find(params[:id])
    fail ActionController::RoutingError.new('这里没有你找的东西') unless @app

    @app.update(app_params)

    redirect_to apps_path
  end

  def destroy
    App.find_by(slug: params[:slug]).destroy
    redirect_to apps_path
  end

  def show
    @app = App.find_by(slug: params[:slug])
    authorize @app
    fail ActionController::RoutingError.new('这里没有你找的东西') unless @app

    if ! @app.password.blank? || user_signed_in?
      @release = @app.releases.last
    else
      redirect_to new_user_session_path
    end
  end

  def auth
    @app = App.find_by(slug: params[:slug])

    if @app.password == params[:password]
      cookies[:auth] = { value: Digest::MD5.hexdigest(@app.password), expires: Time.now + 1.week }
      redirect_to app_path(@app.slug)
    else
      flash[:danger] = '密码错误，请重新输入'
      render :show
    end
  end

  def release
    app = App.find_by(slug: params[:slug])
    @release = Release.find_by(app: app, version: params[:id])
    @app = @release.app

    render 'apps/show'
  end

  def upload

  end

  def branches
    @app = App.find_by(slug: params[:slug])
    @branches = @app.branches
    @releases = @app.releases.where(branch: params[:branch]).order(created_at: :desc) if params[:branch]
  end

  private

    def check_user_logged_in!
      authenticate_user! unless request.user_agent.include? 'MicroMessenger'
    end

    def app_params
      params.require(:app).permit(:user_id, :name, :device_type, :identifier, :slug, :password)
    end
end
