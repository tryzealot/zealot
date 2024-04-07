# frozen_string_literal: true

module ChannelsHelper
  def using_friendly_channel_path(scheme, channel)
    device_type = channel.device_type
    real_channel = scheme.channels.find_by(device_type: device_type)
    real_channel ||= scheme.channels.where.not(device_type: device_type).take
    return nil unless real_channel

    friendly_channel_overview_path(real_channel)
  end
end
