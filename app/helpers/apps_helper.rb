# frozen_string_literal: true

module AppsHelper
  SelectOption = Struct.new(:name, :value)

  DEFAULT_SCHEMES = %w[测试版 内测版 产品版].freeze
  DEFAULT_CHANNELS = [
    SelectOption.new('Android', 'android'),
    SelectOption.new('iOS', 'ios'),
    SelectOption.new('Android 和 iOS', 'both')
  ].freeze

  def default_schemes
    DEFAULT_SCHEMES
  end

  def default_channels
    DEFAULT_CHANNELS
  end

  def app_icon?(release, options = {})
    return unless release&.icon && release.icon.file && release.icon.file.exists?

    size = options.delete(:size) || :thumb
    image_tag(release.icon_url(size), options)
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
    if git_url.include?('git@')
      # git@git.example.com:user/repo.git
      git_url = git_url.sub(':', '/').sub('git@', 'http://').sub('.git', '')
    end
    commit_url = File.join(git_url, 'commit', commit)

    raw "<a href='#{commit_url}' >#{commit[0..(commit_length - 1)]}</a>"
  end

  def display_app_device(channel)
    return channel.name if channel.name.downcase == channel.device_type.downcase

    device_type = case channel.device_type.downcase
                  when 'ios'
                    'iOS'
                  when 'iphone'
                    'iPhone'
                  when 'ipad'
                    'iPad'
                  when 'universal'
                    'Universal'
                  when 'android'
                    'Android'
                  else
                    channel.device_type
                  end

    "#{channel.name} (#{device_type})"
  end
end
