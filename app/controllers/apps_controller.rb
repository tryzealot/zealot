# frozen_string_literal: true

class AppsController < ApplicationController
  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_app, only: %i[show edit update destroy]
  before_action :process_scheme_and_channel, only: %i[create]


  def index
    @title = t('apps.apps')
    @apps = App.all
    authorize @apps
  end

  def show
    @title = @app.name
  end

  def new
    @title = t('apps.new_app')
    @app = App.new
    authorize @app

    @app.schemes.build
  end

  def edit
    @title = t('apps.edit_app')
  end

  def create
    @app = App.new(app_params)
    authorize @app

    return render :new unless @app.save

    @app.users << current_user
    app_create_schemes_and_channels
    redirect_to apps_path, notice: t('apps.messages.create_app_success', name: @app.name)
  end

  def update
    @app.update(app_params)
    redirect_to apps_path
  end

  def destroy
    @app.destroy
    destory_app_data

    redirect_to apps_path
  end

  private

  def destory_app_data
    require 'fileutils'
    app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
    logger.debug "Delete app all binary and icons in #{app_binary_path}"
    FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)
  end

  def app_create_schemes_and_channels
    @schemes.each do |scheme_name|
      scheme = @app.schemes.create(name: scheme_name)
      next if @channels.empty?

      @channels.each do |channel_name|
        scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
      end
    end
  end

  def set_app
    @app = App.find(params[:id])
    authorize @app
  end

  def process_scheme_and_channel
    @schemes = app_params.delete(:scheme_attributes)[:name].reject(&:empty?)
    @channels = app_params.delete(:channel_attributes)[:name].reject(&:empty?)
  end

  def app_params
    @app_params ||= params.require(:app)
                          .permit(
                            :name,
                            scheme_attributes: { name: [] },
                            channel_attributes: { name: [] },
                          )
  end

  def render_not_found_entity_response(e)
    redirect_to apps_path, notice: t('apps.messages.not_found_app', id: e.id)
  end
end
