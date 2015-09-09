class RenameVersionInJsPatch < ActiveRecord::Migration
  def change
    rename_column :jspatches, :version, :app_version
  end
end
