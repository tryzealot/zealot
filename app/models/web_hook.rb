class WebHook < ApplicationRecord
  belongs_to :channel

  has_rich_text :body
end
