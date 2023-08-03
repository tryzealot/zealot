class AddDeviceIdToDevice < ActiveRecord::Migration[7.0]
  def change
    add_column :devices, :device_id, :string
  end
end
