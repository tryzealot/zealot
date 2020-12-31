# frozen_string_literal: true

class SchemesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_scheme, except: %i[create new]
  before_action :set_app

  def show
    if (referer = request.referer) &&
       (segment = Rails.application.routes.recognize_path(referer)) &&
       segment[:controller] == 'channels' &&
       segment[:action] == 'show'
      previouse_channel = Channel.friendly.find(segment[:id])
      @channel = @scheme.channels.find_by(device_type:  previouse_channel.device_type)
    else
      @channel = @scheme.latest_channel
    end

    redirect_to channel_path(@channel)
  end

  def new
    @title = "新建#{@app.name}类型"
    @scheme = Scheme.new
    authorize @scheme
  end

  def create
    channel = scheme_params.delete(:channel)
    @scheme = Scheme.new(scheme_params)
    authorize @scheme

    @scheme.app = @app
    return render :new unless @scheme.save

    create_channel_by(@scheme, channel)
    redirect_to app_path(@app), notice: '类型已经创建成功！'
  end

  def edit
    @title = "编辑#{@app.name}类型"
    raise ActionController::RoutingError, '这里没有你找的东西' unless @scheme
  end

  def update
    raise ActionController::RoutingError, '这里没有你找的东西' unless @scheme

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
    authorize @scheme
  end

  def scheme_params
    @scheme_params ||= params.require(:scheme)
                             .permit(:name, :channel)
  end
end
