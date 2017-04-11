class CleanChatroom < ActiveRecord::Migration[5.0]
  def change
    drop_table :groups
    drop_table :messages
  end
end
