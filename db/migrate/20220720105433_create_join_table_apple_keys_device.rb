class CreateJoinTableAppleKeysDevice < ActiveRecord::Migration[7.0]
  def change
    create_join_table :apple_keys, :devices do |t|
      t.index [:apple_key_id, :device_id]
      t.index [:device_id, :apple_key_id]
    end
  end
end
