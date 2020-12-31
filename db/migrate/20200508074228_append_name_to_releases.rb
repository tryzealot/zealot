class AppendNameToReleases < ActiveRecord::Migration[6.0]
  def up
    add_column :releases, :name, :string, null: true
  end

  def down
    remove_column :releases, :name
  end
end
