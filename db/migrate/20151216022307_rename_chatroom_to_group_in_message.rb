class RenameChatroomToGroupInMessage < ActiveRecord::Migration
  def change
    rename_column :messages, :chatroom_name, :group_name
    rename_column :messages, :chatroom_type, :group_type
    add_column :messages, :group_id, :integer, index: true, null: false, after: :id
    remove_column :messages, :chatroom_id
  end
end
