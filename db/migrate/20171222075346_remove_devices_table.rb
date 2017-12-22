class RemoveDevicesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :devices
  end
end
