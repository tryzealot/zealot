# frozen_string_literal: true

class Device < ApplicationRecord
  has_and_belongs_to_many :releases
  has_and_belongs_to_many :apple_keys

  def self.create_from_api(response)
    current_udid = response.udid
    record_data = {
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

  def channels
    Channel.distinct.where(id: Device.find_by(udid: self.udid)
           .releases
           .select(:channel_id))
  end

  def lastest_release
    releases.last
  end
end
