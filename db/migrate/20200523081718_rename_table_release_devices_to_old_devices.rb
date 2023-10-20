class RenameTableReleaseDevicesToOldDevices < ActiveRecord::Migration[6.0]
  def up
    rename_column :releases, :devices, :legacy_devices
    # migrate_devices
  end

  def down
    # rollback_device
    rename_column :releases, :legacy_devices, :devices
  end

  private

  def migrate_devices
    Release.find_each do |release|
      next if release.legacy_devices.empty?

      release.legacy_devices.each do |udid|
        device = Device.find_or_create_by!(udid: udid)
        release.devices << device
      end
    end
  end

  def rollback_device
    Release.find_each do |release|
      devices = release.devices.map { |d| d.udid }
      release.update_column(:legacy_devices, devices)
    end
  end
end
