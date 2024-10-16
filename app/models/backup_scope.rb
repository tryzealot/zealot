# frozen_string_literal: true

class BackupScope < ApplicationRecord
  DATABASE = 'database'
  CHANNEL = 'channel'

  belongs_to :backup

  enum :key, { database: DATABASE, channel: CHANNEL }

  scope :database?, -> { exists?(key: DATABASE) }
  scope :channel?, -> { exists?(key: CHANNEL) }
  scope :channel_ids, -> {
    select("value->'data' AS channel_ids")
      .find_by(key: CHANNEL)
      &.channel_ids
  }
end
