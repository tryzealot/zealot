class AddMoreInfoToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :filesize, :integer, after: :app_id
    add_column :releases, :extra, :text, after: :changelog
  end
end
