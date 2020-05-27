# frozen_string_literal: true

class Device < ApplicationRecord
  has_and_belongs_to_many :releases

  def channels
    Channel.where(id: Device.find_by(udid: self.udid)
           .releases
           .distinct
           .select(:channel_id))
  end

  def last_release
    releases.last
  end
end
