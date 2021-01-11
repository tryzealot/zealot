class RemoveLegacyDevicesFromReleases < ActiveRecord::Migration[6.0]
  def change
    remove_column :releases, :legacy_devices, :string
  end
end
