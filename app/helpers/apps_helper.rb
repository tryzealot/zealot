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
    return image_tag('touch-icon-60.png', options) unless release&.icon && release.icon.file && release.icon.file.exists?

    size = options.delete(:size) || :thumb
    image_tag(release.icon_url(size), options)
  end

  def app_release_auth_key(release)
    "app_release_#{release.id}_auth"
  end

  def logged_in_or_without_auth?(release)
    puts user_signed_in?
    puts matched_password?(release)
    user_signed_in? || matched_password?(release)
  end

  def matched_password?(release)
    channel = release.channel
    password = channel.password

    # no password euqal matched password
    return true if password.blank?

    cookies[app_release_auth_key(release)] == encode_password(channel)
  end

  def encode_password(channel)
    Digest::MD5.hexdigest(channel.password)
  end

  def create_or_update_release
    ActiveRecord::Base.transaction do
      if new_record?
        create_new_build
      else
        update_new_build
      end
    end
  end

  def new_record?
    @channel.blank?
  end

  # 创建 App 并创建新版本
  def create_new_build
    create_release with_channel and_scheme and_app
  end

  # 使用现有 App 创建新版本
  def update_new_build
    message = "bundle id `#{app_info.bundle_id}` not matched with `#{@channel.bundle_id}` in channel #{@channel.id}"
    raise TypeError, message unless @channel.bundle_id_matched? app_info.bundle_id

    create_release with_updated_channel
  end

  def with_updated_channel
    @channel.update! channel_params
    @channel
  end

  def create_release(channel)
    @release = channel.releases.create! release_params do |release|
      release.bundle_id = app_info.bundle_id
      release.release_version = app_info.release_version
      release.build_version = app_info.build_version
      release.release_type ||= app_info.release_type if app_info.os == AppInfo::Parser::Platform::IOS
      release.icon = File.open(app_info.icons.last[:file])
    end
  end

  def with_channel(scheme)
    scheme.channels.create! channel_params do |channel|
      channel.name = app_info.os
      channel.device_type = app_info.os
    end
  end

  def and_scheme(app)
    name = parse_scheme_name || '测试版'
    app.schemes.create! name: name
  end

  def and_app
    permitted = params.permit(:name)
    permitted[:name] = app_info.name unless permitted.key?(:name)

    App.create! permitted do |app|
      app.user = @user
    end
  end

  def parse_scheme_name
    return unless app_info.os == AppInfo::Parser::Platform::IOS

    case app_info.release_type
    when AppInfo::Parser::IPA::ExportType::DEBUG
      '开发版'
    when AppInfo::Parser::IPA::ExportType::ADHOC
      '测试版'
    when AppInfo::Parser::IPA::ExportType::INHOUSE
      '企业版'
    when AppInfo::Parser::IPA::ExportType::RELEASE
      '线上版'
    end
  end

  # def qr_code(url)
  #   qrcode = RQRCode::QRCode.new(url, level: :h)
  #   raw qrcode.as_svg(
  #     color: '465960',
  #     fill: 'F4F5F6',
  #     module_size: 7,
  #     offset: 15
  #   )
  # end

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
