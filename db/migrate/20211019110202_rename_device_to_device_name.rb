class RenameDeviceToDeviceName < ActiveRecord::Migration[6.1]
  def change
    rename_column :releases, :device, :device_type
  end
end
