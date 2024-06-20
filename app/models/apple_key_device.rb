# frozen_string_literal: true

class AppleKeyDevice < ApplicationRecord
  self.table_name = 'apple_keys_devices'

  belongs_to :apple_key
  belongs_to :device
end
