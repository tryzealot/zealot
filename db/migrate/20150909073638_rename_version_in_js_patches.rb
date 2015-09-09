class RenameVersionInJsPatches < ActiveRecord::Migration
  def change
    rename_column :jspatches, :min_version, :version
    remove_column :jspatches, :max_version

    add_index :jspatches, [:app_id, :version], name: 'index_jspatches_on_app_id_and_version'
  end
end
