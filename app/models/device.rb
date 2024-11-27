# frozen_string_literal: true

class Device < ApplicationRecord
  has_and_belongs_to_many :releases
  has_and_belongs_to_many :apple_keys

  # TODO: why name must requires?
  # validates :name, presence: true

  attr_accessor :sync_to_apple_key

  def self.create_from_api(response)
    current_udid = response.udid
    record_data = {
      device_id: response.id,
      name: response.name,
      model: response.device,
      platform: response.platform,
      status: response.status,
      created_at: Time.parse(response.added_date)
    }

    device = find_by(udid: current_udid)
    if device.blank?
      device = create(record_data.merge(udid: current_udid))
    else
      device.update!(record_data)
    end

    if block_given?
      device = yield device
    end

    device
  end

  def sync_devices_job(apple_key_id)
    SyncDeviceNameJob.perform_later(apple_key_id, id)
  end

  def channels
    Channel.distinct.where(id: Device.find_by(udid: self.udid)
           .releases
           .select(:channel_id))
  end

  def lastest_release
    releases.last
  end

  def sync_to_apple_key
    @sync_to_apple_key || '1'
  end
end
