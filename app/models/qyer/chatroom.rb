class Qyer::Chatroom < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'app_chatroot'
  self.inheritance_column = 'chatroom_type'

  has_many :messages

  paginates_per 100
end
