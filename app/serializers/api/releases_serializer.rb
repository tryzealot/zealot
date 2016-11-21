class Api::ReleasesSerializer < ActiveModel::Serializer
  attributes :version, :release_version, :build_version

  belongs_to :app_id
end
