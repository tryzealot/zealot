# frozen_string_literal: true

module ApplicationHelper
  RANDOM_COLORS = %w[aqua blue purple navy maroon yellow red].freeze

  def button_link_to(title, url, icon = nil, **options)
    options[:class] += ' btn'

    title = %(<i class="fa fa-#{icon}"></i>#{title}) unless icon.blank?

    link_to raw(title), url, **options
  end

  def random_color
    "bg-#{RANDOM_COLORS[rand(RANDOM_COLORS.size - 1)]}"
  end

  def timeline_app_icon(device_type)
    device_type == 'android' ? 'fa-android bg-green' : 'fa-apple bg-black'
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

  def changelog_format(changelog)
    raw = changelog.each_with_object([]) do |line, obj|
      obj << "- #{line['message']}"
    end.join("\n")

    simple_format raw
  end

  def device_name(device_type)
    case device_type.downcase
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
      device_type
    end
  end

  def device_icon(device_type)
    icon = case device_type.downcase
           when 'ios', 'iphone', 'ipad', 'mac', 'ipa'
             'fa-apple'
           when 'android', 'apk'
             'fa-android'
           else
             'fa-adn'
           end

    raw %(<i class="fa #{icon}"></i>)
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
    !(source =~ /iPhone|iPad|Unversal|ios|iOS/i).nil?
  end

  def android?(source = nil)
    source ||= user_agent
    !(source =~ /Android|android/i).nil?
  end

  # 检查移动设备
  def detect_device(device)
    if ios?(user_agent) && ios?(device)
      :ios
    elsif android?(user_agent) && android?(device)
      :android
    else
      :unkown
    end
  end
end
