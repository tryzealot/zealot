class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :role_id
      t.string :action
      t.string :resource
      t.timestamps null: false
    end
  end
end
