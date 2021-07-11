# frozen_string_literal: true

module ApplicationHelper
  def user_signed_in_or_guest_mode?
    user_signed_in? || (Setting.guest_mode && !devise_page?)
  end

  def devise_page?
    params[:controller].start_with?('devise/')
  end

  def button_link_to(title, url, icon = nil, **options)
    options[:class] += ' btn'

    content = title
    if icon.present?
      content = tag.i(class: "fas fa-#{icon}")
      content += title
    end

    link_to content, url, **options
  end

  # 激活 li 的 class
  def active_class(link_paths, class_name = 'active')
    link_paths = [ link_paths ] if link_paths.is_a?(String)

    is_current = false
    link_paths.each do |link|
      if current_page?(link)
        is_current = true
        break
      end
    end

    is_current ? class_name : ''
  end

  def changelog_format(changelog, **options)
    raw = changelog.each_with_object([]) do |line, obj|
      obj << "- #{line['message']}"
    end.join("\n")

    simple_format raw, **options
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

    tag.i(class: "fab #{icon}")
  end

  def timeline_app_icon(device_type)
    device_type == 'android' ? 'fa-android bg-green' : 'fa-apple bg-black'
  end

  # 获取浏览器 user agent
  delegate :user_agent, to: :request

  def wechat?
    user_agent.include?('MicroMessenger')
  end

  def ios?(source = nil)
    # iPadOS: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Safari/605.1.15
    source ||= user_agent
    (source =~ /iPhone|iPad|Unversal|ios|iOS/i).present?
  end

  def android?(source = nil)
    source ||= user_agent
    source.downcase.include?('android')
  end

  def phone?
    ios? || android?
  end

  def mac?
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
    source ||= user_agent
    source.downcase.include?('macintosh')
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

  def omniauth_display_name(provider)
    case provider
    when :ldap
      provider.to_s.upcase
    else
      OmniAuth::Utils.camelize(provider).sub('Oauth2', '')
    end
  end
end
