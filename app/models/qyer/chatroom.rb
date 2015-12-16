class Qyer::Chatroom < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'app_chatroot'
  self.inheritance_column = 'chatroom_type'

  has_one :group, -> { where(type: 'chatroom') }, foreign_key: 'qyer_id'
end
