class Api::Apps::VersionsController < Api::BaseController
  before_action :validate_user_token
  before_action :validate_channel_key

  def index
    # @releases = @channel.releases
    #                     .order(version: :desc)
    #                     .page(params.fetch(:page, 1))
    #                     .per(params.fetch(:per_page, 20))


    # @releases.each do |release|
    #   data[:releases] << {
    #     id: release.id,
    #     version: release.version,
    #     release_version: release.release_version,
    #     build_version: release.build_version,
    #     icon_url: release.icon_url,
    #     install_url: release.install_url,
    #     changelog: release.changelog
    #   }
    # end

    render json: @channel,
           serializer: Api::AppVersionsSerializer,
           page: params.fetch(:page, 1).to_i,
           per_page: params.fetch(:per_page, 10).to_i
  end

  private

  def set_channel
    @channel = Channel.friendly.find params[:slug]
  end
end
