class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :permissions, dependent: :destroy
end
