# frozen_string_literal: true

class Device < ApplicationRecord
  has_and_belongs_to_many :releases
  has_and_belongs_to_many :apple_keys

  def channels
    Channel.distinct.where(id: Device.find_by(udid: self.udid)
           .releases
           .select(:channel_id))
  end

  def lastest_release
    releases.last
  end
end
