class AddArchivedToApps < ActiveRecord::Migration[8.0]
  def change
    add_column :apps, :archived, :boolean, default: false, null: false
  end
end