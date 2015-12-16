class Message < ActiveRecord::Base
  belongs_to :group
  belongs_to :member

  paginates_per 100
end
