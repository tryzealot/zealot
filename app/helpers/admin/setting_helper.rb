# frozen_string_literal: true

module Admin::SettingHelper
  def display_value(key, value)
    empty_value = t('admin.settings.empty_value')
    return empty_value if value.nil? || (value.respond_to?(:empty?) && value.empty?)

    case value
    when Hash
      enabled = value[:enabled]
      return pretty_json(value) if enabled.nil?

      text = display_value(key, enabled)
      case key
      when 'passwordless_login_enabled'
        expired = distance_of_time_in_words_to_now(value[:token_expiry_in_minutes].minutes.since)
        enabled ? "#{text} (#{expired})" : text
      else
        text
      end
    when Array
      value.join(', ')
    when TrueClass
      t('admin.settings.enable')
    when FalseClass
      t('admin.settings.disable')
    else
      t("settings.#{key}.#{value}", default: value.to_s)
    end
  end

  def vcs_ref_link(ref)
    link = if Rails.env.development?
        github_repo_compare_commit(ref, 'main')
      else
        docker_tag? ? github_repo_compare_commit(ref, Setting.version) : github_version_link
      end

    link_to ref, link, target: :blank
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
