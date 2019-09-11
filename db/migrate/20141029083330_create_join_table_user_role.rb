class CreateJoinTableUserRole < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :roles do |t|
      t.index [:user_id, :role_id]
      t.index [:role_id, :user_id]
    end
  end
end
