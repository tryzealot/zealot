# frozen_string_literal: true

class ChannelsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_channel, only: %i[show edit update destroy]
  before_action :set_scheme, except: %i[show]

  def show
    @web_hook = @channel.web_hooks.new
    @releases = @channel.releases
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 10))
                        .order(id: :desc)
    @versions = @channel.release_versions(5)
  end

  def new
    @channel = Channel.new
    authorize @channel

    @title = "新建#{@scheme.app_name}渠道"
  end

  def create
    @channel = Channel.new(channel_params)
    authorize @channel

    if @channel.save
      redirect_to app_path(@channel.scheme.app), notice: t('activerecord.success.create', key: "#{@channel.scheme.name} #{@channel.name} 渠道")
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
    @scheme = Scheme.find(params[:scheme_id])
  end

  def set_channel
    @channel = Channel.friendly.find params[:id]
    authorize @channel

    @app = @channel.scheme.app
    @title = @channel.app_name
    @subtitle = " #{@app.schemes.count} 类型共 #{@channel.scheme.channels.count} 渠道"
  end

  def channel_params
    params.require(:channel).permit(
      :scheme_id, :name, :device_type, :bundle_id,
      :slug, :password, :git_url
    )
  end

  def render_not_found_entity_response(e)
    redirect_to apps_path, notice: "没有找到应用渠道 #{e.id}，跳转至应用列表"
  end
end
