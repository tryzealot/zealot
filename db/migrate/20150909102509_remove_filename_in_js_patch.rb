class RemoveFilenameInJsPatch < ActiveRecord::Migration
  def change
    remove_index  :jspatches, :filename
    remove_column :jspatches, :filename
  end
end
