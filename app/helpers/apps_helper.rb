# frozen_string_literal: true

module AppsHelper
  def preset_schemes
    Setting.preset_schemes || Setting.builtin_schemes.values
  end

  def preset_channels
    Channel.device_types.values
  end

  def app_channel_columns(schemes_total)
    case schemes_total
    when 1 then 12
    when 2 then 6
    else 4
    end
  end

  def app_icon(release, options = {})
    unless release&.icon && release.icon.file && release.icon.file.exists?
      return image_tag('zealot-icon.png', **options)
    end

    options[:data] ||= {}
    options[:data][:release_id] ||= release.id
    options[:data][:channel_id] ||= release.channel.slug
    image_tag(release.icon_url, **options)
  end

  def app_device(device)

  end

  def logged_in_or_without_auth?(release)
    user_signed_in? || matched_password?(release)
  end

  def matched_password?(release)
    release.cookie_password_matched?(cookies)
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

    if params[:name] == branch
      branch
    else
      link_to(branch, friendly_channel_branches_path(release.channel, name: branch))
    end
  end

  def release_type_url_builder(release)
    return unless release_type = release.release_type
    return if release_type.blank?

    title = release_type_name(release_type)
    if params[:name] == release_type
      title
    else
      link_to(title, friendly_channel_release_types_path(release.channel, name: release_type))
    end
  end

  def channel_platform(channel)
    return channel.name if channel.name.downcase == channel.device_type.downcase

    platform = platform_name(channel.device_type)
    channel.name == platform ? channel.name : "#{channel.name} (#{platform_name(channel.device_type)})"
  end

  def changelog_render(changelog, **options)
    source = options.delete(:source) || :markdown
    case source
    when :markdown
      content_tag(:div, **options) do
        raw Kramdown::Document.new(changelog).to_html
      end
    else
      simple_format changelog, **options
    end
  end

  def app_qrcode_tag(release)
    if Setting.site_appearance != 'auto'
      theme = current_user&.appearance || Setting.site_appearance
      return image_tag channel_release_qrcode_path(@release.channel, @release,
        size: :large, theme: theme)
    end

    content_tag(:picture) do
      qrcode_uri = channel_release_qrcode_path(release.channel, release, size: :large, theme: :dark)
      content_tag(:source, media: "(prefers-color-scheme: dark)",  srcset: qrcode_uri) do
        image_tag channel_release_qrcode_path(release.channel, release, size: :large)
      end
    end
  end
end
