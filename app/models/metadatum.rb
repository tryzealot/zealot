# frozen_string_literal: true

class Metadatum < ApplicationRecord
  belongs_to :release
  belongs_to :user

  enum platform: {
    ios: 'ios',
    android: 'android',
    mobileprovision: 'mobileprovision',
    macos: 'macos',
    windows: 'windows'
  }

  alias_attribute :packet_name, :bundle_id

  paginates_per     50
  max_paginates_per 100

  def app
    return unless release

    release.app
  end
end
