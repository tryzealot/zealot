class Message < ActiveRecord::Base
  belongs_to :chatroom
  belongs_to :member

  self.per_page = 100
end
