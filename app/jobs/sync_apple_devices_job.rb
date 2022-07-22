# frozen_string_literal: true

class SyncAppleDevicesJob < ApplicationJob
  queue_as :schedule

  def perform(apple_key_id = nil)
    apple_key_id ? sync_devices_by_apple_key(apple_key_id) : sync_all_devices
  rescue => e
    logger.error "Throws an error [#{e.class}] #{e.message}"
  end

  private

  def sync_all_devices
    AppleKey.all.each do |apple_key|
      apple_key.sync_devices
    end
  end

  def sync_devices_by_apple_key(apple_key_id)
    apple_key = AppleKey.find(apple_key_id)
    apple_key.sync_devices
  end
end
