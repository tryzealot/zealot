# frozen_string_literal: true

class Api::LatestAppSerializer < ApplicationSerializer
  # channel model based
  attributes :app_name, :bundle_id, :git_url

  belongs_to :app
  belongs_to :scheme
  has_many   :releases

  def releases
    release_version = instance_options[:release_version]
    build_version = instance_options[:build_version]
    if release_version.blank? && build_version.blank?
      object.releases.last
    else
      object.find_since_version(release_version, build_version)
    end
  end
end
