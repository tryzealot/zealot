# frozen_string_literal: true

class ReleaseSerializer < ApplicationSerializer
  attributes :version, :app_name, :bundle_id, :release_version, :build_version,
             :source, :branch, :git_commit, :ci_url, :size,
             :icon_url, :install_url, :changelog,
             :created_at

  def changelog
    object.array_changelog(false)
  end
end
