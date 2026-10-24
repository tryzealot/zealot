# frozen_string_literal: true

class SchemesController < ApplicationController
  include AppArchived
  
  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_app
  before_action :set_scheme, except: %i[index create new]
  before_action :process_scheme_params, only: %i[create]

  def index
    @title = t('schemes.title')
    @schemes = @app.schemes.includes(:channels)
    authorize @app, :index?
  end

  def show
    @title = t('schemes.title')
    authorize @app, :show?
  end

  def new
    @page_title =t('.title.with_name', app: @app.name)
    @title = t('.title.without_name')
    @scheme = @app.schemes.build
    authorize @scheme
  end

  def create
    channels = scheme_params.delete(:channel_attributes)[:name].reject(&:blank?)
    @scheme = @app.schemes.new(scheme_params)
    authorize @scheme

    return render :new, status: :unprocessable_entity unless @scheme.save

    create_channels(channels)

    flash.now[:notice] = t('activerecord.success.create', key: "#{@scheme.name} #{t('schemes.title')}")
    respond_to do |format|
      format.html { redirect_to app_path(@app) }
      format.turbo_stream
    end
  end

  def edit
    authorize @scheme
    @page_title =t('.title.with_name', app: @app.name)
    @title = t('.title.without_name')
  end

  def update
    authorize @scheme
    @scheme.update(scheme_params)

    flash.now[:notice] = t('activerecord.success.update', key: "#{@scheme.name} #{t('schemes.title')}")
    respond_to do |format|
      format.html { redirect_to app_path(@app) }
      format.turbo_stream
    end
  end

  def destroy
    authorize @scheme
    @scheme.destroy

    flash.now[:notice] = t('activerecord.success.destroy', key: "#{@scheme.name} #{t('schemes.title')}")
    respond_to do |format|
      format.html { redirect_to app_path(@app) }
      format.turbo_stream
    end
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
    raise_if_app_archived!(@app) unless %w[index show].include?(action_name)
  end

  def set_scheme
    @scheme = @app.schemes.find(params[:id])
  end

  def scheme_params
    @scheme_params ||= params.require(:scheme)
                             .permit(:name, :new_build_callout, :retained_builds, channel_attributes: { name: [] })
  end

  def process_scheme_params
    @channels = scheme_params[:channel_attributes][:name].reject(&:empty?)
  end
end
