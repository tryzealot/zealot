# frozen_string_literal: true

module DashboardHelper # rubocop:disable Metrics/ModuleLength
  def device_icon(device_type, i_class: nil)
    icon, _ = device_style(device_type)
    tag.i(class: "fa-brands #{icon} #{i_class}")
  end

  def timeline_app_icon(value)
    icon, bg_color = device_style(value)
    tag.div(class: "size-8 rounded-full #{bg_color} flex items-center justify-center text-base-content/70") do
      tag.i(class: "fa-brands #{icon} text-white fa-lg")
    end
  end

  def device_style(device_type)
    case device_type.downcase
    when 'ios', 'appletv'
      ['fa-apple', 'bg-gray-700']
    when 'android'
      ['fa-android', 'bg-green-600']
    when 'harmonyos'
      ['fa-adn', 'bg-black']
    when 'windows'
      ['fa-windows', 'bg-primary']
    when 'macos'
      ['fa-app-store', 'bg-blue']
    when 'linux'
      ['fa-linux', 'bg-info']
    else
      ['fa-adn', 'bg-blue-400']
    end
  end
end
