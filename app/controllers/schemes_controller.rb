# frozen_string_literal: true

class SchemesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_scheme, except: %i[create new]
  before_action :set_channel, only: %i[show]
  before_action :set_app

  def show
    if @channel
      redirect_to channel_path(@channel)
    else
      redirect_to new_app_scheme_channel_path(@scheme.app, @scheme), alert: t('schemes.show.empty_channel')
    end
  end

  def new
    @title = t('schemes.new.title', app: @app.name)
    @scheme = Scheme.new
    authorize @scheme
  end

  def create
    channels = scheme_params.delete(:channel_attributes)[:name].reject(&:empty?)
    @scheme = Scheme.new(scheme_params)
    authorize @scheme

    @scheme.app = @app
    return render :new unless @scheme.save

    create_channels(channels)
    redirect_to app_path(@app), notice: t('activerecord.success.create', key: t('schemes.title'))
  end

  def edit
    @title = t('schemes.edit.title', app: @app.name)
  end

  def update
    @scheme.update(scheme_params)
    redirect_to app_path(@app)
  end

  def destroy
    @scheme.destroy

    redirect_to app_path(@app)
  end

  protected

  def create_channels(channels)
    return if channels.empty?

    channels.each do |channel_name|
      @scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
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
                             .permit(:name, channel_attributes: { name: [] })
  end

  def set_channel
    from_channel, segment = from_channel?
    unless from_channel
      @channel = @scheme.latest_channel
      return
    end

    previouse_channel = Channel.friendly.find(segment[:id])
    @channel = @scheme.channels.find_by(device_type:  previouse_channel.device_type)
  end

  def from_channel?
    return [false, nil] unless referer = request.referer
    return [false, nil] unless segment = Rails.application.routes.recognize_path(referer)

    from_channel = segment[:controller] == 'channels' && segment[:action] == 'show'

    [from_channel, segment]
  end
end
