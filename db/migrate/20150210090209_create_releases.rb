class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.integer :app_id, null: false
      t.string :release_version, null: false
      t.string :build_version, null: false
      t.string :identifier, null: false
      t.integer :version
      t.string :store_url
      t.string :icon
      t.text :changelog

      t.timestamps
    end

    add_index :releases, :app_id
    add_index :releases, [:app_id, :version], name: 'index_releases_on_app_id_and_version', unique: true
    add_index :releases, :identifier
  end
end
