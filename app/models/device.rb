class Device < ApplicationRecord
  include FriendlyId
  friendly_id :udid
end
