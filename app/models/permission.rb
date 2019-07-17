class Permission < ApplicationRecord
  belongs_to :role
  has_many :users, through: :role
end
