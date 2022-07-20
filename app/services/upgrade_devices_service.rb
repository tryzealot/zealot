# frozen_string_literal: true

class UpgradeDevicesService < ApplicationService
  include ActionView::Helpers::TranslationHelper

  attr_reader :file

  # def initialize()
  #   @file = file
  # end

  def call
    AppleKey.all.each do |apple_key|
      update_device(apple_key)
    end
  end

  private

  def update_device(apple_key)
    Device.all.each do |model|
      puts "Finding udid: #{model.udid}"
      # FIXME: 有问题，老的设备根本没有关联，因此需要更新 devices 的参数并关联 apple key
      begin
        device = apple_key.device(model.udid)
        model.update(
          name: device.name,
          platform: device.platform,
          model: device.model,
          created_at: Time.parse(device.added_date)
        )
        puts " => updated"
      rescue => e
        puts " => not found, #{e}"
        # not found
        next
      end
    end
  end
end