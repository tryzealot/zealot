# frozen_string_literal: true

module ApplicationHelper
  def page_title(title)
    "#{title} - #{site_title}"
  end

  def site_title
    Setting.site_title
  end

  def new_or_create_route?
    current_page?(action: 'new') ||  current_page?(action: 'create')
  end

  def user_signed_in_or_guest_mode?
    user_signed_in? || (Setting.guest_mode && !devise_page?)
  end

  def demo_mode?
    Setting.demo_mode
  end

  def devise_page?
    # current_page? method CAN NOT fuzzy matching
    contoller_name = params[:controller]
    contoller_name.start_with?('devise/') || contoller_name == 'users/registrations'
  end

  def button_link_to(title, url, icon = nil, **options)
    options[:class] = 'btn ' + options[:class]
    base_fontawesome = options.delete(:base_fa) || 'fas'

    content = title
    if icon.present?
      content = tag.i(class: "#{base_fontawesome} fa-#{icon}")
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
    when 'macos'
      'macOS'
    else
      device_type
    end
  end

  def device_icon(device_type)
    icon, _ = device_style(device_type)
    tag.i(class: "fab #{icon}")
  end

  def timeline_app_icon(device_type)
    device_style(device_type).join(' ')
  end

  def device_style(device_type)
    case device_type.downcase
    when 'ios'
      ['fa-apple', 'bg-black']
    when 'android'
      ['fa-android', 'bg-green']
    when 'windows'
      ['fa-windows', 'bg-warning']
    when 'macos'
      ['fa-app-store', 'bg-blue']
    else
      ['fa-adn', 'bg-lightblue']
    end
  end

  # 获取浏览器 user agent
  delegate :user_agent, to: :request

  def app_limited?
    user_agent.include?('MicroMessenger') || user_agent.include?('DingTalk')
  end

  # Intel: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko)
  #        Chrome/75.0.3770.100 Safari/537.36
  # Arm M1: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko)
  #        Chrome/91.0.4472.114 Safari/537.36
  def macos?(source = nil)
    source ||= user_agent
    source.downcase.include?('macintosh')
  end

  # iPadOS: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko)
  #         Version/13.0 Safari/605.1.15
  def ios?(source = nil)
    source ||= user_agent
    (source =~ /iPhone|iPad|Unversal|ios|iOS/i).present?
  end

  def android?(source = nil)
    source ||= user_agent
    source.downcase.include?('android')
  end

  # 检查设备
  def detect_device(device, target)
    value = if ios?(device)
              :ios
            elsif android?(device)
              :android
            elsif macos?(device)
              :macos
            else
              :unkown
            end

    value == target.to_sym
  end

  def github_repo_commit(ref)
    "#{Setting.repo_url}/commit/#{ref}"
  end
end
