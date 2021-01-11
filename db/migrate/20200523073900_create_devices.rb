class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.string :udid, unique: true, null: false, index: true
      t.string :name

      t.timestamps
    end
  end
end
