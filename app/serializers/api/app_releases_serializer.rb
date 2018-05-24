class Api::AppReleasesSerializer < Api::BaseSerializer
  attributes :id, :name, :identifier, :device_type, :slug, :icon_url

  has_many :releases do
    Kaminari.paginate_array(object.releases.order(version: :desc))
  end

  class ReleaseSerializer < ActiveModel::Serializer
    attributes :id, :version, :release_version, :build_version, :changelog, :icon_url, :install_url
  end
end
