class Group < ActiveRecord::Base
  has_many :messages
  self.inheritance_column = 'chatroom_type'

  paginates_per 100
end
