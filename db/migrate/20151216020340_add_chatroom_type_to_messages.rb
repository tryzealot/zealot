class AddChatroomTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :chatroom_type, :string, after: :chatroom_name, default: 'chatroom'
  end
end
