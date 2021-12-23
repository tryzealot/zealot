# frozen_string_literal: true

module ChannelsHelper
  def using_friendly_channel_path(scheme, channel)
    channel = scheme.channels.find_by(device_type:  channel.device_type)
    friendly_channel_path(channel)
  end
end
