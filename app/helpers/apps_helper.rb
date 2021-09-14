# frozen_string_literal: true

module AppsHelper
  def default_schemes
    Setting.default_schemes
  end

  def default_channels
    Channel.device_types.values
  end

  def app_icon(release, options = {})
    unless release&.icon && release.icon.file && release.icon.file.exists?
      return image_pack_tag('media/images/touch-icon.png', options)
    end

    image_tag(release.icon_url, options)
  end

  def app_release_auth_key(release)
    "app_release_#{release.id}_auth"
  end

  def logged_in_or_without_auth?(release)
    user_signed_in? || matched_password?(release)
  end

  def matched_password?(release)
    channel = release.channel
    password = channel.password

    # no password euqal matched password
    return true if password.blank?

    cookies["app_release_#{release.id}_auth"] == channel.encode_password
  end

  def git_commit_url(git_url, commit, commit_length = 8)
    return if commit.blank?

    commit_name = commit[0..(commit_length - 1)]
    return commit_name if git_url.blank?

    if git_url.include?('git@')
      # git@git.example.com:user/repo.git
      git_url = git_url.sub(':', '/').sub('git@', 'http://').sub('.git', '')
    end
    commit_url = File.join(git_url, 'commit', commit)

    content_tag(:a, commit_name, href: commit_url)
  end

  def git_branch_url(release)
    return unless branch = release.branch
    return if branch.blank?

    link_to(branch, channel_branches_path(release.channel, name: branch))
  end

  def release_type_url(release)
    return unless release_type = release.release_type
    return if release_type.blank?

    link_to(release_type, channel_release_types_path(release.channel, name: release_type))
  end

  def display_app_device(value)
    if value.is_a?(Release)
      channel = value.channel
      channal_device_type = device_name(channel.device_type)
      if value.device
        return channal_device_type == value.device ? channal_device_type : "#{channal_device_type} (#{value.device})"
      end
    else
      channel = value
    end

    return channel.name if channel.name.downcase == channel.device_type.downcase

    platform = device_name(channel.device_type)
    channel.name == platform ? channel.name : "#{channel.name} (#{device_name(channel.device_type)})"
  end
end
