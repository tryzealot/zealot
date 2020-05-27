class AddModelToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :model, :string
  end
end
