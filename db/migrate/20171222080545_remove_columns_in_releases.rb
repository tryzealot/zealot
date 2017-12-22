class RemoveColumnsInReleases < ActiveRecord::Migration[5.1]
  def up
    remove_column :releases, :distribution
    remove_column :releases, :store_url
    remove_column :releases, :md5
  end

  def down
    add_column :releases, :distribution, :string
    add_column :releases, :store_url, :string
    add_column :releases, :md5, :string
  end
end
