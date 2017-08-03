class RemovePacColumnIsEnable < ActiveRecord::Migration[5.0]
  def change
    remove_column :pacs, :is_enabled
  end
end
