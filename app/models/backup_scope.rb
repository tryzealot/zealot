# frozen_string_literal: true

class BackupScope < ApplicationRecord
  DATABASE = 'database'
  CHANNEL = 'channel'

  belongs_to :backup

  scope :database?, -> { exists?(key: DATABASE) }
  scope :channel?, -> { exists?(key: CHANNEL) }

  enum key: { database: DATABASE, channel: CHANNEL }

  def channels
    return if key == DATABASE

    value['data'].each_with_object([]) do |channel_id, obj|
      begin
        obj << Channel.find(channel_id)
      rescue
        next
      end
    end
  end
end
