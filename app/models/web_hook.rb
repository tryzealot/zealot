class WebHook < ApplicationRecord
  belongs_to :channel
  validates :channel_id, :url, presence: true
end
