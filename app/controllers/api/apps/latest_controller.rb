class Api::Apps::LatestController < Api::BaseController
  before_action :validate_channel_key

  def show
    headers['Last-Modified'] = Time.now.httpdate

    render json: @channel,
           serializer: Api::LatestAppSerializer,
           release_version: params[:release_version],
           build_version: params[:build_version]
  end
end
