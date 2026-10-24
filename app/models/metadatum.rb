# frozen_string_literal: true

class Metadatum < ApplicationRecord
  belongs_to :release
  belongs_to :user
  # Teardowns uploaded inside an app keep that app, the rest only reach an app
  # through their release.
  belongs_to :app, optional: true

  enum :platform, {
    ios: 'ios',
    appletv: 'appletv',
    android: 'android',
    mobileprovision: 'mobileprovision',
    macos: 'macos',
    windows: 'windows',
    harmonyos: 'harmonyos'
  }

  alias_attribute :packet_name, :bundle_id

  paginates_per     50
  max_paginates_per 100

  def app
    super || release&.app
  end
end
