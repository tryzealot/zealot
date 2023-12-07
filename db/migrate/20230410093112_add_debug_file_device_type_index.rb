class AddDebugFileDeviceTypeIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :debug_files, [:id, :device_type]
    add_index :debug_files, [:app_id, :device_type]
  end
end
