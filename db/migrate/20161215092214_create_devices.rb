class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :udid
      t.string :model
      t.string :platform
      t.string :device_type

      t.timestamps
    end

    add_index :devices, :udid, unique: true
  end
end
