# frozen_string_literal: true

module AppsHelper
  SelectOption = Struct.new(:name, :value)

  DEFAULT_SCHEMES = %w[测试版 内测版 产品版]
  DEFAULT_CHANNELS = [
    SelectOption.new('Android 和 iOS', 'both'),
    SelectOption.new('Android', 'android'),
    SelectOption.new('iOS', 'ios')
  ]

  def default_schemes
    DEFAULT_SCHEMES
  end

  def default_channels
    DEFAULT_CHANNELS
  end

  def app_icon(release, options = {})
    unless release&.icon && release.icon.file && release.icon.file.exists?
      return image_pack_tag('media/images/touch-icon.png', options)
    end

    size = options.delete(:size) || :thumb
    image_tag(release.icon_url(size), options)
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

    cookies[app_release_auth_key(release)] == channel.encode_password
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
      return "#{device_name(channel.device_type)} (#{value.device})" if value.device
    else
      channel = value
    end

    return channel.name if channel.name.downcase == channel.device_type.downcase
    return "#{channel.name} (#{device_name(channel.device_type)})"
  end
end
