class Role < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :permissions, dependent: :destroy

  def self.default_role
    find_by(value: 'user')
  end
end
