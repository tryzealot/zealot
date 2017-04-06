class Pac < ActiveRecord::Base
  validates :title, :script, presence: true
end
