# frozen_string_literal: true

module AppsHelper
  def preset_schemes
    Setting.preset_schemes || Setting.builtin_schemes.values
  end

  def preset_channels
    Channel.device_types.values
  end

  def app_scheme_columns(schemes_total)
    md_cols = schemes_total >= 2 ? 2 : 1
    lg_cols = schemes_total >= 4 ? 3 : schemes_total
    xl_cols = schemes_total >= 4 ? 4 : schemes_total

    "grid grid-cols-1 md:grid-cols-#{md_cols} lg:grid-cols-#{lg_cols} xl:grid-cols-#{xl_cols}"
  end

  APP_ICON_CLASS = ["app-icon"]
  def app_icon(release, options = {})
    image_class = options.delete(:class).to_s.split(' ')
    image_class = (APP_ICON_CLASS + image_class).uniq
    unless release&.icon && release.icon.file && release.icon.file.exists?
      options[:class] = image_class.push('app-empty-icon').join(' ')
      return image_tag('zealot-icon.png', **options)
    end
    
    options[:class] = image_class
    image_tag(release.icon_url, **options)
  end

  def native_codes(release)
    native_codes = release.native_codes
    return if native_codes.blank?

    count = native_codes.size
    return t('releases.show.multi_native_codes') if count > 1
    
    native_codes[0]
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

    link_to(commit_name, commit_url, data: { turbo: false })
  end

  def git_branch_url(release)
    return unless branch = release.branch
    return if branch.blank?

    if params[:name] == branch
      branch
    else
      link_to(
        branch,
        friendly_channel_branches_path(release.channel, name: branch),
        data: { turbo_frame: '_top' }
      )
    end
  end

  def release_type_url_builder(release)
    return unless release_type = release.release_type
    return if release_type.blank?

    title = release_type_name(release_type)
    if params[:name] != release_type && user_signed_in_or_guest_mode?
      link_to(
        title, 
        friendly_channel_release_types_path(release.channel, name: release_type), 
        data: { turbo_frame: '_top' }
      )
    else
      title
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
    appearance = active_appearance
    if (appearance) != 'auto'
      return image_tag channel_release_qrcode_path(
        @release.channel, @release,
        size: :lg, theme: appearance, format: :svg)
    end

    content_tag(:picture) do
      qrcode_uri = channel_release_qrcode_path(release.channel, release, size: :lg, theme: :dark, format: :svg)
      content_tag(:source, media: "(prefers-color-scheme: dark)",  srcset: qrcode_uri) do
        image_tag channel_release_qrcode_path(release.channel, release, size: :lg, format: :svg)
      end
    end
  end

  def archived_path?
    current_page?(controller: 'apps/archives')
  end
end
