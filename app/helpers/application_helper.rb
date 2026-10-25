# frozen_string_literal: true

module ApplicationHelper # rubocop:disable Metrics/ModuleLength
  def page_title(title)
    "#{title} - #{site_title}"
  end

  # Titles for pages inside the app context read "{app} · {entry}", where the
  # second half is the app sidebar entry that leads to the page. The document
  # title, the section heading and the sidebar then all read the same. Returns
  # the entry alone when there is no app context (e.g. the global debug files
  # list) so a global page keeps a plain title.
  def app_scoped_title(app, entry)
    [app&.name, entry].compact_blank.join(' · ')
  end

  def site_title
    Setting.site_title
  end

  def site_themes
    {
      light: current_user&.light_theme || Setting.site_light_theme,
      dark: current_user&.dark_theme || Setting.site_dark_theme
    }.to_json
  end

  def active_theme
    return current_user.light_theme if current_user&.appearance == 'light'
    return current_user.dark_theme if current_user&.appearance == 'dark'

    return Setting.site_light_theme if Setting.site_appearance == 'light'
    return Setting.site_dark_theme if Setting.site_appearance == 'dark'

    'auto'
  end

  def active_appearance
    current_user&.appearance || Setting.site_appearance
  end

  def new_or_create_route?
    current_page?(action: 'new') || current_page?(action: 'create') ||
    params[:action] == 'new' || params[:action] == 'create'
  end

  def user_signed_in_or_guest_mode?
    user_signed_in? || (Setting.guest_mode && !devise_page?)
  end

  def devise_page?
    # current_page? method CAN NOT fuzzy matching
    contoller_name = params[:controller]
    return false if contoller_name == 'users/registrations' && params[:action] == 'edit'

    contoller_name.start_with?('devise/') || contoller_name == 'users/registrations' ||
      contoller_name == 'users/confirmations' || contoller_name == 'users/sessions'
  end

  def sidebar_link_to(icon, path, text:, active_path: nil, active: nil, li_class: nil, link_class: nil, **options)
    active = active_class(active_path || path) if active.nil?
    active = 'd-menu-active' if active == true
    active = '' if active == false

    link_class = "d-is-drawer-close:d-tooltip d-is-drawer-close:d-tooltip-right py-2 #{active} #{link_class}"
    tag.li(class: li_class) do
      link_to path, class: link_class.squish, data: { tip: text }, **options do
        concat(tag.i(class: icon))
        concat(tag.span(text, class: 'text-base d-is-drawer-close:hidden'))
      end
    end
  end

  # The app the current request belongs to, used to switch the sidebar to the app context.
  # Only persisted records qualify: `apps#new` and `#create` hold an unsaved @app,
  # which must not switch the sidebar (or build any URLs) for an app without an id.
  def current_nav_app
    return @current_nav_app if defined?(@current_nav_app)

    @current_nav_app = [
      @app, @scheme&.app, @channel&.scheme&.app, @debug_file&.app, @release&.channel&.scheme&.app
    ].compact.find(&:persisted?) || (params[:app_id].present? ? App.find_by(id: params[:app_id]) : nil)
  end

  # Breadcrumb trail for the current request. Controllers can pin it by setting
  # @breadcrumbs (see Breadcrumbable#set_app_breadcrumbs); otherwise it is derived
  # from the app/scheme/channel the current action loaded, so new pages get a trail
  # for free.
  def breadcrumbs
    @breadcrumbs || auto_breadcrumbs
  end

  def auto_breadcrumbs
    Breadcrumbable.build(
      app: @app || @debug_file&.app,
      scheme: @scheme,
      channel: @channel || @release&.channel,
      url: self
    )
  end

  def sidebar_presenter(app)
    @sidebar_presenter ||= SidebarPresenter.new(app: app, user: current_user)
  end

  def icon_link_to(icon, path, **options)
    link_options = options[:link]
    link_to(path, **link_options) do
      icon_options = options[:icon] || {}
      icon_options[:class] = "#{icon} #{icon_options[:class]}"
      concat(tag.i(**icon_options))

      text = options[:text]
      if block_given?
        text = yield
      end

      concat(text) if text.present?
    end
  end

  def button_link_to(title, url, icon = nil, **options)
    options[:class] = "d-btn #{options[:class]}"
    base_fontawesome = options.delete(:base_fa) || 'fa-solid'

    content = title
    if icon.present?
      content = tag.i(class: "#{base_fontawesome} fa-#{icon}")
      content += title
    end

    link_to content, url, **options
  end

  # Return active class if current page matches any of the link paths
  def active_class(link_paths, class_name = 'd-menu-active')
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
  
  def platform_name(platform)
    case platform.downcase
    when 'ios'
      'iOS'
    when 'appletv'
      'Apple TV'
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
    when 'windows'
      'Windows'
    when 'harmonyos'
      'HarmonyOS'
    else
      platform
    end
  end

  def device_name(device)
    case device.downcase.to_sym
    when AppInfo::Device::Apple::IPHONE
      'iPhone'
    when AppInfo::Device::Apple::IPAD
      'iPad'
    when AppInfo::Device::Apple::UNIVERSAL
      'Universal'
    when AppInfo::Device::Apple::APPLETV
      'tvOS'
    when AppInfo::Device::Google::PHONE
      'Phone'
    when AppInfo::Device::Google::WATCH
      'Watch'
    when AppInfo::Device::Google::TELEVISION
      'TV'
    when AppInfo::Device::Google::TABLET
      'Tablet'
    when AppInfo::Device::Google::AUTOMOTIVE
      'Automotive'
    when AppInfo::Device::Microsoft::WINDOWS
      'Windows'
    when AppInfo::Device::Apple::MACOS
      'macOS'
    when AppInfo::Device::Huawei::DEFAULT
      'HarmonyOS'
    when AppInfo::Device::Huawei::PHONE
      'Phone'
    when AppInfo::Device::Huawei::TABLET
      'Tablet'
    when AppInfo::Device::Huawei::TV
      'TV'
    when AppInfo::Device::Huawei::WEARABLE
      'Wearable'
    when AppInfo::Device::Huawei::CAR
      'Car'
    when AppInfo::Device::Huawei::TWO_IN_ONE
      '2-in-1'
    else device
    end
  end

  # iOS build type
  def release_type_name(release_type)
    case release_type.downcase.to_sym
    when :adhoc
      'AdHoc'
    else
      release_type.capitalize
    end
  end

  def github_repo_commit(ref)
    "#{Setting.repo_url}/commit/#{ref}"
  end

  def powered_by
    safe_join([
      'Powered by', 
      link_to('Zealot', 'https://zealot.ews.im')
    ], ' ')
  end

  def zealot_version
    link_to Setting.version_info(suffix: true), Setting.repo_url
  end

  def show_api
    return unless openapi_endpoints_enabled?

    locale = current_user&.locale || I18n.default_locale
    I18n.with_locale(locale) do
      # FIXME: patch to switch locale with hard-code
      language = I18n.t(locale, scope: 'settings.site_locale', default: :en)
      append_path = "/index.html?urls.primaryName=#{language}"

      link_to 'API', "#{api_openapi_ui_path}#{append_path}", target: '_blank'
    end
  end

  def openapi_endpoints_enabled?
    Rails.application.routes.named_routes.key?(:api_openapi_ui) && Setting.show_footer_openapi_endpoints
  end

  def drawer_status
    default_status = mobile_device? ? 'closed' : 'open'
    cookies.fetch(drawer_status_key, default_status) == 'open'
  end

  def drawer_status_key
    'zealot-drawer-status'
  end

  def mobile_device?
    request.user_agent&.match?(/Mobile|webOS|iPhone|iPad|iPod|Android|BlackBerry|IEMobile|Opera Mini/i)
  end
end
