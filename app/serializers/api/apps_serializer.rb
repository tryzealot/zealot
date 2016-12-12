class Api::AppsSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :device_type, :slug, :release_version, :build_version

  attribute :icon_url

  attributes :created_at, :updated_at

  def latest_release
    @release ||= object.releases.last
  end
end
