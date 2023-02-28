# frozen_string_literal: true

module Admin
  module SettingHelper
    def vcs_ref_link(ref)
      link = if Rails.env.development?
          github_repo_compare_commit(ref, 'main')
        else
          docker_tag? ? github_repo_compare_commit(ref, Setting.version) : github_version_link
        end

      link_to ref, link, target: :blank
    end

    def zealot_version(suffix: false)
      version = Setting.version
      return "#{version}-dev" if Rails.env.development?
      return version if !docker_tag? || !suffix

      "#{version}-#{ENV['DOCKER_TAG']}"
    end

    private

    def github_repo_compare_commit(target, base)
      "#{Setting.repo_url}/compare/#{base}...#{target}"
    end

    def github_version_link
      "#{Setting.repo_url}/releases/tag/#{Setting.version}"
    end

    def docker_tag?
      ENV['DOCKER_TAG'].present?
    end
  end
end
