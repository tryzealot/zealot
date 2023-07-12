# frozen_string_literal: true

class SyncDeviceNameJob < ApplicationJob
  queue_as :schedule

  def perform(apple_key_id, device_id)
    apple_key = AppleKey.find(apple_key_id)
    device = Device.find(device_id)
    apple_key.update_device_name(device)
  rescue => e
    logger.error "Throws an error [#{e.class}] #{e.message}"
  end
end
