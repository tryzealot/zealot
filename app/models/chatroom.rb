class Chatroom < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'app_chatroot'

  self.inheritance_column = 'chatroom_type'
end
