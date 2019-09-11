class CreateWebHooks < ActiveRecord::Migration[6.0]
  def change
    create_table :web_hooks do |t|
      t.references :channel, index: true, foreign_key: { on_delete: :cascade }
      t.string :url, index: true
      t.text :body
      t.integer :upload_events, limit: 1
      t.integer :download_events, limit: 1
      t.integer :changelog_events, limit: 1

      t.timestamps
    end
  end
end
