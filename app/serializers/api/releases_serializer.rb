class Api::ReleasesSerializer < Api::BaseSerializer
  attributes :version, :release_version, :build_version

  belongs_to :app_id
end
