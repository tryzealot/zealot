# frozen_string_literal: true

class Api::Apps::VersionsController < Api::BaseController
  before_action :validate_channel_key

  # GET /api/apps/versions
  def index
    render json: @channel,
           serializer: Api::AppVersionsSerializer,
           page: params.fetch(:page, 1).to_i,
           per_page: params.fetch(:per_page, 10).to_i
  end
end
