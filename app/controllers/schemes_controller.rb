# frozen_string_literal: true

class SchemesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_scheme, except: %i[create new]
  before_action :process_scheme_params, only: %i[create]
  before_action :set_channel, only: %i[show]
  before_action :set_app

  def new
    @title = t('schemes.new.title', app: @app.name)
    @scheme = @app.schemes.build
    authorize @scheme
  end

  def create
    channels = scheme_params.delete(:channel_attributes)[:name].reject(&:blank?)
    @scheme = @app.schemes.new(scheme_params)
    authorize @scheme

    return render :new, status: :unprocessable_entity unless @scheme.save

    create_channels(channels)
    redirect_to app_path(@app), notice: t('activerecord.success.create', key: t('schemes.title'))
  end

  def edit
    authorize @scheme
    @title = t('schemes.edit.title', app: @app.name)
  end

  def update
    authorize @scheme
    @scheme.update(scheme_params)
    redirect_to app_path(@app)
  end

  def destroy
    authorize @scheme
    @scheme.destroy

    redirect_to app_path(@app), status: :see_other
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
  end

  def scheme_params
    @scheme_params ||= params.require(:scheme)
                             .permit(:name, :new_build_callout, :retained_builds, channel_attributes: { name: [] })
  end

  def process_scheme_params
    @channels = scheme_params[:channel_attributes][:name].reject(&:empty?)
  end
end
