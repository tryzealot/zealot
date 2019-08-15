class SchemesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_scheme, except: [:index, :create, :new]
  before_action :set_app

  ##
  # 查看应用详情
  # GET /apps/:slug
  def show
    @channel = @scheme.latest_channel
    redirect_to controller: :channels, action: :show, id: @channel.slug if @channel
  end

  ##
  # 新应用页面
  # GET /apps/new
  def new
    @title = "新建#{@app.name}类型"
    @scheme = Scheme.new
  end

  ##
  # 创建新应用
  # POST /apps/create
  def create
    channel = scheme_params.delete(:channel)

    @scheme = Scheme.new(scheme_params)
    @scheme.app = @app
    return render :new unless @scheme.save

    create_channel_by(@scheme, channel)
    redirect_to app_path(@app), notice: '类型已经创建成功！'
  end

  ##
  # 编辑应用页面
  # GET /apps/:slug/edit
  def edit
    @title = "编辑#{@app.name}类型"
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @scheme
  end

  ##
  # 更新应用
  # PUT /apps/:slug/update
  def update
    rails ActionController::RoutingError.new('这里没有你找的东西') unless @scheme
    @scheme.update(scheme_params)

    redirect_to app_path(@app)
  end

  ##
  # 清除应用及所属所有发型版本和上传的二进制文件
  # DELETE /apps/:slug/destroy
  def destroy
    @scheme.destroy

    redirect_to app_path(@app)
  end

  protected

  def create_channel_by(scheme, channel)
    return unless channels = channel_value(channel)

    channels.each do |channel_name|
      scheme.channels.create name: channel_name
    end
  end

  def channel_value(platform)
    case platform
    when 'ios' then ['iOS']
    when 'android' then ['Android']
    when 'both' then ['Android', 'iOS']
    end
  end


  def set_app
    @app = App.find(params[:app_id])
  end

  def set_scheme
    @scheme = Scheme.find(params[:id])
  end

  def scheme_params
    @scheme_params ||= params.require(:scheme)
                             .permit(:name, :channel)
  end
end
