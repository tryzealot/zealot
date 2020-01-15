# frozen_string_literal: true

module AppsHelper
  SelectOption = Struct.new(:name, :value)

  DEFAULT_SCHEMES = %w[测试版 内测版 产品版].freeze
  DEFAULT_CHANNELS = [
    SelectOption.new('Android 和 iOS', 'both'),
    SelectOption.new('Android', 'android'),
    SelectOption.new('iOS', 'ios')
  ].freeze

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
    commit_name = commit[0..(commit_length - 1)]
    return commit_name if git_url.blank?

    if git_url.include?('git@')
      # git@git.example.com:user/repo.git
      git_url = git_url.sub(':', '/').sub('git@', 'http://').sub('.git', '')
    end
    commit_url = File.join(git_url, 'commit', commit)

    raw "<a href='#{commit_url}' >#{commit_name}</a>"
  end

  def display_app_device(channel)
    return channel.name if channel.name.downcase == channel.device_type.downcase

    "#{channel.name} (#{device_name(channel.device_type)})"
  end
end
