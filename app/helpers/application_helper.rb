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
    when 'linux'
      'Linux'
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
      ['fa-apple', 'bg-secondary']
    when 'android'
      ['fa-android', 'bg-green']
    when 'windows'
      ['fa-windows', 'bg-primary']
    when 'macos'
      ['fa-app-store', 'bg-blue']
    when 'linux'
      ['fa-linux', 'bg-info']
    else
      ['fa-adn', 'bg-lightblue']
    end
  end

  def github_repo_commit(ref)
    "#{Setting.repo_url}/commit/#{ref}"
  end
end
