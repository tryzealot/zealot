class AppPlatformToDevices < ActiveRecord::Migration[7.0]
  def change
    add_column :devices, :platform, :string
  end
end
