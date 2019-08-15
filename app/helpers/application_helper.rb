# frozen_string_literal: true

module ApplicationHelper
  RANDOM_COLORS = %w[aqua blue purple navy maroon yellow red].freeze

  def random_color
    "bg-#{RANDOM_COLORS[rand(RANDOM_COLORS.size - 1)]}"
  end

  # 激活 li 的 class
  def active_class(link_path = nil)
    if link_path
      current_page?(link_path) ? 'active' : ''
    elsif current_page?(controller: 'groups', action: 'messages') ||
          current_page?(controller: 'groups', action: 'index') ||
          current_page?(controller: 'users', action: 'groups')
      'active'
    else
      ''
    end
  end

  # 获取浏览器 user agent
  def user_agent
    request.user_agent
  end

  def wechat?
    user_agent.include?('MicroMessenger')
  end

  def ios?(source = nil)
    source ||= user_agent
    !(source =~ /iPhone|iPad/i).nil?
  end

  def android?(source = nil)
    source ||= user_agent
    !(source =~ /Android/i).nil?
  end

  # 移动设备甄别
  def detect_device(device)
    if ios?(user_agent) && ios?(device)
      'iOS'
    elsif android?(user_agent) && android?(device)
      'Android'
    else
      'Other'
    end
  end
end
