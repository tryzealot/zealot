class CreateWebHooks < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.string :url
      t.references :app
      t.integer :upload_events
      t.integer :changelog_events
      t.timestamps null: false
    end

    add_index :web_hooks, :app_id
    add_index :web_hooks, :url
  end
end
