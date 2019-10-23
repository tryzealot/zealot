class CreateReleases < ActiveRecord::Migration[6.0]
  def change
    create_table :releases do |t|
      t.references :channel, index: true, foreign_key: { on_delete: :cascade }
      t.string :bundle_id, null: false, index: true
      t.integer :version, null: false, index: true
      t.string :release_version, null: false, index: true
      t.string :build_version, null: false, index: true
      t.string :release_type, null: true, index: true
      t.string :source, null: true, index: true
      t.string :branch, null: true
      t.string :git_commit, null: true
      t.string :icon, null: true
      t.string :ci_url, null: true
      t.jsonb :changelog, null: false
      t.string :file, null: true
      t.jsonb :devices, null: false, default: []

      t.timestamps
    end

    add_index :releases, [:channel_id, :version], unique: true
    add_index :releases, [:release_version, :build_version]
  end
end
