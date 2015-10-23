class CreateUserApps < ActiveRecord::Migration
  def change
    create_table :user_apps do |t|
      t.integer :user_id
      t.integer :app_id
    end

    add_index :user_apps, [:user_id, :app_id]
  end
end
