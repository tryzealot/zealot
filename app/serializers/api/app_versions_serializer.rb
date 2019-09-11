class Api::AppVersionsSerializer < ApplicationSerializer
  # channel model based
  attributes :app_name, :bundle_id, :git_url

  belongs_to :app
  belongs_to :scheme
  has_many   :releases

  def releases
    release_version = instance_options[:release_version]
    build_version = instance_options[:build_version]
    object.releases
          .where('release_version >= ? AND build_version > ?', release_version, build_version)
          .order(version: :desc)
  end
end
