class RemoveIosTable < ActiveRecord::Migration
  def change
    drop_table :ios
  end
end
