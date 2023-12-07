# frozen_string_literal: true

class ReleaseSerializer < ApplicationSerializer
  attributes :version, :app_name, :bundle_id, :release_version, :build_version,
             :source, :branch, :git_commit, :ci_url, :size, :platform, :device_type,
             :icon_url, :install_url, :changelog, :text_changelog, :custom_fields,
             :created_at


  def changelog
    object.array_changelog(default_template: false)
  end

  def text_changelog
    object.text_changelog(default_template: false)
  end
end
