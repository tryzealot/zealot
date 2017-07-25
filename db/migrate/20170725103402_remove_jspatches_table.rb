class RemoveJspatchesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :jspatches
  end
end
