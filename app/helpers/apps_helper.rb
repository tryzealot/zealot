module AppsHelper
  def app_icon?(release, options = {})
    if release && release.icon && release.icon.file && release.icon.file.exists?
      size = options.delete(:size) || :thumb
      image_tag(release.icon_url(size), options)
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
    if git_url.include?('git@')
      # git@git.example.com:user/repo.git
      git_url = git_url.sub(':', '/').sub('git@', 'http://').sub('.git', '')
    end
    commit_url = File.join(git_url, 'commit', commit)

    raw "<a href='#{commit_url}' >#{commit[0..commit_length-1]}</a>"
  end

  def display_app_device(app)
    case app.device_type.downcase
    when 'ios'
      'iOS'
    when 'iphone'
      'iPhone'
    when 'ipad'
      'iPad'
    when 'android'
      'Android'
    else
      app.device_type
    end
  end
end
