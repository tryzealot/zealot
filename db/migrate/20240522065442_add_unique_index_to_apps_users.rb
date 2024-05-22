class AddUniqueIndexToAppsUsers < ActiveRecord::Migration[7.1]
  def change
    remove_index :apps_users, [:user_id, :app_id]
    remove_index :apps_users, [:app_id, :user_id]

    add_index :apps_users, [:app_id, :user_id], unique: true
    add_index :apps_users, [:user_id, :app_id], unique: true
  end
end
