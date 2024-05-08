# frozen_string_literal: true

class Api::ChannelsController < Api::BaseController
  before_action :set_scheme, only: %i[index create]
  before_action :set_channel, only: %i[show update destroy]

  # GET /api/schemes/:scheme_id/channels
  def index
    render json: @scheme.channels
  end

  # POST /api/schemes/:scheme_id/channels
  def create
    @channel = @scheme.channels.create!(channel_params)

    render json: @channel
  end

  # GET /api/channels/:id
  def show
    render json: @channel
  end

  # PUT /api/channels/:id
  def update
    @channel.update!(channel_params)
    render json: @channel
  end

  # DELETE /api/channels/:id
  def destroy
    @channel.destroy!
    render json: {}
  end

  protected

  def set_scheme
    @scheme = Scheme.find(params[:scheme_id])
  end

  def set_channel
    @channel = Channel.find(params[:id])
  end

  def channel_params
    @channel_params ||= params.permit(:name, :slug, :device_type, :bundle_id, :password, :git_url)
  end
end
