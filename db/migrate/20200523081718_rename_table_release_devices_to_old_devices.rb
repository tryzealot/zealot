class RenameTableReleaseDevicesToOldDevices < ActiveRecord::Migration[6.0]
  def up
    rename_column :releases, :devices, :legacy_devices
  end

  def down
    rename_column :releases, :legacy_devices, :devices
  end
end
