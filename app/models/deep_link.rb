class DeepLink < ApplicationRecord
  validates :name, :category, :links, presence: true
end
