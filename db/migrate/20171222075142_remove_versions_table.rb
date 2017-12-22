class RemoveVersionsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :versions
  end
end
