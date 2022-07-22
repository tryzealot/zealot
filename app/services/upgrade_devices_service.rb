# frozen_string_literal: true

class UpgradeDevicesService < ApplicationService
  include ActionView::Helpers::TranslationHelper

  attr_reader :file

  def call
    AppleKey.all.each do |apple_key|
      apple_key.sync_devices
    end
  end
end