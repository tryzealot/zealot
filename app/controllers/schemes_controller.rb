class SchemesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_scheme, except: [:index, :create, :new]
  before_action :set_app

  def show
    @channel = @scheme.latest_channel
    redirect_to controller: :channels, action: :show, id: @channel.slug if @channel
  end

  def new
    @title = "新建#{@app.name}类型"
    @scheme = Scheme.new
  end

  def create
    channel = scheme_params.delete(:channel)

    @scheme = Scheme.new(scheme_params)
    @scheme.app = @app
    return render :new unless @scheme.save

    create_channel_by(@scheme, channel)
    redirect_to app_path(@app), notice: '类型已经创建成功！'
  end

  def edit
    @title = "编辑#{@app.name}类型"
    raise ActionController::RoutingError.new('这里没有你找的东西') unless @scheme
  end

  def update
    raise ActionController::RoutingError.new('这里没有你找的东西') unless @scheme
    @scheme.update(scheme_params)

    redirect_to app_path(@app)
  end

  def destroy
    @scheme.destroy

    redirect_to app_path(@app)
  end

  protected

  def create_channel_by(scheme, channel)
    return unless channels = channel_value(channel)

    channels.each do |channel_name|
      scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
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
