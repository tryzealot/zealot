class AddDeviceToRelease < ActiveRecord::Migration[6.0]
  def change
    add_column :releases, :device, :string
  end
end
