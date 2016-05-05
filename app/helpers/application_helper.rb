module ApplicationHelper
  ##
  # 格式化 emoji 表情
  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      match_string = Regexp.last_match(1)
      emoji = Emoji.find_by_alias(match_string)
      if emoji
        %(<img alt="#match_string" src="#{asset_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end

  ##
  # 激活 li 的 class
  def active_class(link_path = nil)
    if link_path
      current_page?(link_path) ? 'active' : ''
    else
      if current_page?(controller: 'groups', action: 'messages') ||
         current_page?(controller: 'groups', action: 'index') ||
         current_page?(controller: 'users', action: 'groups')
        'active'
      else
        ''
      end
    end
  end

  ##
  # 获取浏览器 user agent
  def user_agent
    request.user_agent
  end

  def ios?(source)
    source =~ /iPhone|iPad/i
    !source.empty?
  end

  def android?(source)
    source =~ /Android/i
    !source.empty?
  end

  ##
  # 移动设备甄别
  def detect_device(device)
    if browser.platform.ios? && ios?(device)
      'iOS'
    elsif browser.platform.android? && android?(device)
      'Android'
    else
      'Other'
    end
  end
end
