class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :im_id
      t.string :im_user_id
      t.string :im_topic_id
      t.integer :chatroom_id
      t.string :chatroom_name
      t.integer :user_id
      t.string :user_name
      t.string :message
      t.text :custom_data
      t.string :content_type
      t.string :file_type
      t.text :file
      t.datetime :timestamp
      t.timestamps    
    end

    add_index :messages, :im_id
    add_index :messages, :im_user_id
    add_index :messages, :im_topic_id
    add_index :messages, :chatroom_id
    add_index :messages, :user_id

  end
end
