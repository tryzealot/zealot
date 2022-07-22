class AppPlatformToDevices < ActiveRecord::Migration[7.0]
  def change
    add_column :devices, :platform, :string
    add_column :devices, :status, :string
  end
end
