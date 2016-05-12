class AppendMoreColumnToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :devices, :text, after: :file, null: true
    add_column :releases, :release_type, :string, after: :version, null: true
    add_column :releases, :distribution, :string, after: :release_type, null: true

    add_index :releases, :version
    add_index :releases, :channel
    add_index :releases, :release_type
    add_index :releases, :release_version
  end
end
