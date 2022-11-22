class CreateBackups < ActiveRecord::Migration[7.0]
  def change
    create_table :backups do |t|
      t.string :key, unique: true, null: false, index: true
      t.string :schedule, null: false
      t.boolean :enabled_database, default: true
      t.integer :enabled_apps, array: true, default: []
      t.integer :max_keeps, default: -1
      t.string :notification
      t.boolean :enabled
      t.timestamps
    end
  end
end
