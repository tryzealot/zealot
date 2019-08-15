class CreatePermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions do |t|
      t.references :role, index: true, foreign_key: { on_delete: :cascade }
      t.string :action
      t.string :resource
      t.timestamps null: false
    end
  end
end
