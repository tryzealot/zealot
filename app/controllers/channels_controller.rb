class ChannelsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_channel, except: [:index, :create, :new, :upload]
  before_action :set_scheme, except: [:index, :show]

  ##
  # 查看应用详情
  # GET /apps/:slug
  def show
    @releases = @channel.releases
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 10))
                        .order(id: :desc)
  end

  ##
  # 新应用页面
  # GET /apps/new
  def new
    @channel = Channel.new

    @title = "新建#{@scheme.app_name}渠道"
  end

  ##
  # 创建新应用
  # POST /apps/create
  def create
    @channel = Channel.new(channel_params)

    if @channel.save
      redirect_to app_path(@channel.scheme.app), notice: "#{@channel.scheme.name} #{@channel.name} 渠道创建成功"
    else
      @channel.errors
    end
  end

  ##
  # 编辑应用页面
  # GET /apps/:slug/edit
  def edit
    @title = '编辑应用'
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
  end

  ##
  # 更新应用
  # PUT /apps/:slug/update
  def update
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @app
    @channel.update(channel_params)

    redirect_to app_path(@app)
  end

  ##
  # 清除应用及所属所有发型版本和上传的二进制文件
  # DELETE /apps/:slug/destroy
  def destroy
    @channel.destroy

    redirect_to app_path(@app)
  end

  # ##
  # # 应用密码认证
  # # GET /apps/auth
  # def auth
  #   if @app.password == params[:password]
  #     cookies[:auth] = { value: Digest::MD5.hexdigest(@app.password), expires: Time.zone.now + 1.week }
  #     redirect_to app_path(@app)
  #   else
  #     flash[:danger] = '密码错误，请重新输入'
  #     render :show
  #   end
  # end

  # ##
  # # 创建新的构建
  # def build
  # end

  protected

  def set_scheme
    @scheme = Scheme.find params[:scheme_id]
  end

  def set_channel
    @channel = Channel.friendly.find params[:id]
    @app = @channel.scheme.app
    @title = "#{@app.name} #{@channel.scheme.name} #{@channel.name}"
  end

  def channel_params
    params.require(:channel).permit(
      :scheme_id, :name, :device_type, :bundle_id,
      :slug, :password, :git_url
    )
  end
end
