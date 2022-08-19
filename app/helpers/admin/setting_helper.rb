# frozen_string_literal: true

module Admin
  module SettingHelper
    def vcs_ref_link(ref)
      base = Setting.version == 'development' ? 'main' : Setting.version
      link_to ref, github_repo_compare_commit(ref, base), target: :blank
    end

    private

    def github_repo_compare_commit(target, base)
      "#{Setting.repo_url}/compare/#{base}...#{target}"
    end

    def docker_nightly_tag?
      ENV['DOCKER_TAG'] == 'nightly'
    end
  end
end