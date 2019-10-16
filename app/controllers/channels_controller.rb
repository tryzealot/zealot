class ChannelsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_channel, only: [:show, :edit, :destroy]
  before_action :set_scheme, except: [:index, :show]

  def show
    @web_hook = @channel.web_hooks.new
    @releases = @channel.releases
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 10))
                        .order(id: :desc)
  end

  def new
    @channel = Channel.new

    @title = "新建#{@scheme.app_name}渠道"
  end

  def create
    @channel = Channel.new(channel_params)

    if @channel.save
      redirect_to app_path(@channel.scheme.app), notice: "#{@channel.scheme.name} #{@channel.name} 渠道创建成功"
    else
      @channel.errors
    end
  end

  def edit
    @title = "编辑#{@scheme.app_name}渠道"
    raise ActionController::RoutingError, '这里没有你找的东西' unless @app
  end

  def update
    raise ActionController::RoutingError, '这里没有你找的东西' unless @app

    @channel.update(channel_params)
    redirect_to app_path(@app)
  end

  def destroy
    @channel.destroy

    redirect_to app_path(@app)
  end

  protected

  def set_scheme
    @scheme = Scheme.find params[:scheme_id]
  end

  def set_channel
    @channel = Channel.friendly.find params[:id]
    @app = @channel.scheme.app
    @title = @channel.app_name
    @subtitle = "#{@app.schemes.count} 种类型共 #{@channel.scheme.channels.count} 个渠道"
  end

  def channel_params
    params.require(:channel).permit(
      :scheme_id, :name, :device_type, :bundle_id,
      :slug, :password, :git_url
    )
  end
end
