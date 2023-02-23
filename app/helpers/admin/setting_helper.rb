# frozen_string_literal: true

module Admin
  module SettingHelper
    def vcs_ref_link(ref)
      base = Rails.env.development? ? 'main' : Setting.version
      link_to ref, github_repo_compare_commit(ref, base), target: :blank
    end

    def zealot_version(suffix: false)
      version = Setting.version
      return version if !docker_tag? || !suffix

      "#{version}-#{ENV['DOCKER_TAG']}"
    end

    private

    def github_repo_compare_commit(target, base)
      "#{Setting.repo_url}/compare/#{base}...#{target}"
    end

    def docker_tag?
      ENV['DOCKER_TAG'].present?
    end
  end
end
