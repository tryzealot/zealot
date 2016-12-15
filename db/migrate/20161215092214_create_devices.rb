class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :udid

      t.timestamps
    end

    add_index :devices, :udid, unique: true
  end
end
