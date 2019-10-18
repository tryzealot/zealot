class CreateJoinTableUserApp < ActiveRecord::Migration[6.0]
  def change
    create_join_table :apps, :users do |t|
      t.index [:user_id, :app_id]
      t.index [:app_id, :user_id]
    end
  end
end
