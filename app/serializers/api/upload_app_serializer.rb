class Api::UploadAppSerializer < ApplicationSerializer
  # release model based
  attributes :version, :app_name, :bundle_id, :release_version, :build_version,
             :source, :branch, :git_commit, :ci_url, :size,
             :icon_url, :install_url, :changelog_list,
             :created_at

  belongs_to :app
  belongs_to :scheme
  belongs_to :channel
end
