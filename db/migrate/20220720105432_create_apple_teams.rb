class CreateAppleTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :apple_teams do |t|
      t.references :apple_key,      index: true, foreign_key: { on_delete: :cascade }
      t.string :team_id,            unique: true
      t.string :name,               null: false
      t.string :display_name,       null: false, default: ''
      t.timestamps
    end
  end
end
