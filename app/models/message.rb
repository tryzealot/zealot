class Message < ActiveRecord::Base
  belongs_to :chatroom
  belongs_to :member

  paginates_per 100
end
