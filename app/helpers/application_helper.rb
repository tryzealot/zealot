module ApplicationHelper
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
