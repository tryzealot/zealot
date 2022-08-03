class CreateBackups < ActiveRecord::Migration[7.0]
  def change
    create_table :backups do |t|
      t.string :key, unique: true, null: false, index: true
      t.string :schedule
      t.integer :max_keeps
      t.string :notification
      t.boolean :enable_archive
      t.boolean :enabled
      t.timestamps
    end
  end
end
