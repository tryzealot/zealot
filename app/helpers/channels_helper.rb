# frozen_string_literal: true

module ChannelsHelper
  def using_friendly_channel_path(scheme, channel)
    device_type = channel.device_type
    real_channel = scheme.channels.find_by(device_type: device_type)
    real_channel ||= scheme.channels.where.not(device_type: device_type).take
    return nil unless real_channel

    friendly_channel_overview_path(real_channel)
  end

  def bulk_delete_url(channel)
    name = params[:name]
    type = params[:controller].split('/')&.last
    return destroy_releases_channel_path(channel) if name.blank?

    case type.to_sym
    when :versions
      friendly_channel_version_path(channel, name: name)
    when :branches
      friendly_channel_branches_path(channel, name: name)
    when :release_types
      friendly_channel_release_types_path(channel, name: name)
    else
      destroy_releases_channel_path(channel)
    end
  end

  def goback_main_path(fallback:)
    request.env['HTTP_REFERER'] || fallback
  end
end
