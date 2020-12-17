# frozen_string_literal: true

class Metadatum < ApplicationRecord
  belongs_to :release
  belongs_to :user

  enum platform: { ios: 'ios', android: 'android', mobileprovision: 'mobileprovision' }

  alias_attribute :packet_name, :bundle_id
end
