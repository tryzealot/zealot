class AddMd5AndFileToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :md5, :string, after: :changelog
    add_column :releases, :file, :string, after: :md5
  end
end
