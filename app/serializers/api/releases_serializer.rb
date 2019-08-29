class Api::ReleasesSerializer < ApplicationSerializer
  attributes :version, :release_version, :build_version

  belongs_to :app_id
end
