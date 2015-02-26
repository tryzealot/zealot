class AppendUserIdToApps < ActiveRecord::Migration
  def change
    add_column :apps, :user_id, :integer, after: :id

    add_index :apps, :user_id
  end
end
