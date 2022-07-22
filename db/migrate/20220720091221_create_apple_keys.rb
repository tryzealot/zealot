class CreateAppleKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :apple_keys do |t|
      t.string :issuer_id,        index: true, null: false
      t.string :key_id,           index: true, null: false
      t.string :filename,         null: false
      t.string :private_key,      null: false
      t.string :checksum,         index: true, null: false

      t.timestamps
    end
  end
end
