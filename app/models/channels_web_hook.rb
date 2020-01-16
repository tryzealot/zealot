# frozen_string_literal: true

class ChannelsWebHook < ApplicationRecord
  belongs_to :channel
  belongs_to :web_hook
end
