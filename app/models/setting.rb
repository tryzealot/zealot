class Setting < ApplicationRecord
  def self.accounts
    Rails.cache.fetch("apple_ids", expires_in: 1.hour) do
      JSON.parse find_by(name: 'apple_ids').value
    end
  end
end
