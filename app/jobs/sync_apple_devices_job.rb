class SyncAppleDevicesJob < ApplicationJob
  queue_as :schedule

  def perform(apple_key_id)
    apple_key = AppleKey.find(apple_key_id)
    apple_key.sync_devices
  rescue => e
    logger.error "Throws an error [#{e.class}] #{e.message}"
  end
end
