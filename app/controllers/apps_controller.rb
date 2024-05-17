# frozen_string_literal: true

class AppsController < ApplicationController
  before_action :authenticate_user! unless Setting.guest_mode
  before_action :set_app, only: %i[show edit update destroy]
  before_action :set_selected_schemes_and_channels, only: %i[edit]
  before_action :process_scheme_and_channel, only: %i[create]

  def index
    @title = t('.title')
    @apps = manage_user_or_guest_mode? ? App.all : current_user.apps.all
    authorize @apps
  end

  def show
    @title = @app.name
  end

  def new
    @title = t('.title')
    @app = App.new
    authorize @app

    @app.schemes.build
  end

  def edit
    @title = t('.title')
  end

  def create
    @app = App.new(app_params)
    authorize @app

    return render :new, status: :unprocessable_entity unless @app.save

    @app.users << current_user
    create_schemes_and_channels
    redirect_to apps_path, notice: t('activerecord.success.create', key: "#{@app.name} #{t('apps.title')}")
  end

  def update
    # if @schemes.empty? && @channels.empty?
    #   flash[:alert] = t('apps.messages.failture.missing_schemes_and_channels')
    #   return render :edit, status: :unprocessable_entity
    # end

    @app.update(app_params)
    redirect_to apps_path
  end

  def destroy
    @app.destroy
    destory_app_data

    redirect_to apps_path, status: :see_other
  end

  private

  def destory_app_data
    require 'fileutils'

    app_binary_path = Rails.root.join('public', 'uploads', 'apps', "a#{@app.id}")
    FileUtils.rm_rf(app_binary_path) if Dir.exist?(app_binary_path)
  end

  def create_schemes_and_channels
    @schemes.each do |scheme_name|
      scheme = @app.schemes.create(name: scheme_name)
      next if @channels.empty?

      @channels.each do |channel_name|
        scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
      end
    end
  end

  # def update_schemes_and_channels
  #   existed_schemes = @app.schemes.all

  #   @schemes.each do |scheme_name|
  #     scheme = @app.schemes.find_by(name: scheme_name)


  #     @channels.each do |channel_name|
  #       scheme.channels.create name: channel_name, device_type: channel_name.downcase.to_sym
  #     end
  #   end
  # end

  def set_selected_schemes_and_channels
    @schemes = []
    @channels = []
    @app.schemes.each do |scheme|
      @schemes << scheme.name

      channels = scheme.channels.pluck(:name)
      channels.each do |channel_name|
        @channels << channel_name unless @channels.include?(channel_name)
      end
    end
  end

  def process_scheme_and_channel
    @schemes = app_params.delete(:scheme_attributes)[:name].reject(&:empty?)
    @channels = app_params.delete(:channel_attributes)[:name].reject(&:empty?)
  end

  def set_app
    @app = App.find(params[:id])
    authorize @app
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
    redirect_to apps_path, notice: t('apps.messages.failture.not_found_app', id: e.id)
  end
end
