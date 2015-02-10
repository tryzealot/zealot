class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :slug, null: false
      t.string :password
      t.string :key
      t.timestamps
    end

    add_index :apps, :name, unique: true
    add_index :apps, :type
    add_index :apps, :slug, unique: true
  end
end
