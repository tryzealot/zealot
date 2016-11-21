class Api::AppsSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :device_type, :slug, :created_at, :updated_at
  has_many :releases, key: :last_release, serializer: Api::ReleasesSerializer do
    object.releases.last
  end

  # def release_version
  #   object.id
  # end
end
