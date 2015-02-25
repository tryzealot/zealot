class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :device_type, null: false
      t.string :password
      t.string :key
      t.timestamps
    end

    add_index :apps, :name
    add_index :apps, :device_type
    add_index :apps, :slug, unique: true
  end
end
