class DeepLink < ApplicationRecord
  def categories
    releases.group(:category)
            .map(&:category)
  end
end
