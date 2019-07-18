class Api::V2::Apps::VersionsController < Api::BaseController
  before_action :validate_app_key, only: [:index, :show]

  def index
    @releases = @app.releases.order(version: :desc)
                             .page(params.fetch(:page, 1))
                             .per(params.fetch(:per_page, 20))

    data = {
      id: @app.id,
      name: @app.name,
      identifier: @app.identifier,
      device_type: @app.device_type,
      slug: @app.slug,
      releases: []
    }

    @releases.each do |release|
      data[:releases] << {
        id: release.id,
        version: release.version,
        release_version: release.release_version,
        build_version: release.build_version,
        icon_url: release.icon_url,
        install_url: release.install_url,
        changelog: release.changelog
      }
    end

    render json: data
  end

  def show

  end
end
