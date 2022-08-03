class CreateBackupScopes < ActiveRecord::Migration[7.0]
  def change
    create_table :backup_scopes do |t|
      t.references :backup, index: true, foreign_key: { on_delete: :cascade }
      t.string :key
      t.jsonb :value, default: {}, null: false
      t.timestamps
    end
  end
end
