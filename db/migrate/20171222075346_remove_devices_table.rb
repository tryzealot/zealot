class RemoveDevicesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :devices
  end

  def down
    create_table :devices do |t|
      t.string :name
      t.string :udid
      t.string :model
      t.string :platform
      t.string :device_type

      t.timestamps
    end
  end
end
