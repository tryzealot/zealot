# frozen_string_literal: true

class Api::LatestAppSerializer < ApplicationSerializer
  # channel model based
  attributes :app_name, :bundle_id, :git_url

  belongs_to :app
  belongs_to :scheme
  has_many   :releases

  def releases
    bundle_id = instance_options[:bundle_id]
    release_version = instance_options[:release_version]
    build_version = instance_options[:build_version]

    if bundle_id.blank?
      if release_version.blank? && build_version.blank?
        return object.releases.order(version: :desc)
      else
        return object.releases.find_since_version(release_version, build_version)
      end
    end

    if release_version.blank? && build_version.blank?
      object.releases.find_by(bundle_id: bundle_id)
    else
      object.find_since_version(bundle_id, release_version, build_version)
    end
  end
end
