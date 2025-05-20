# frozen_string_literal: true

class WebHook < ApplicationRecord
  has_and_belongs_to_many :channels, dependent: :destroy

  delegate :count, to: :channels, prefix: true

  validates :channel_id, :url, presence: true
  validates :body, jb: true
end
