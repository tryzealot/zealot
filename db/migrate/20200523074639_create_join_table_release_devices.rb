class CreateJoinTableReleaseDevices < ActiveRecord::Migration[6.0]
  def change
    create_join_table :releases, :devices do |t|
      t.index [:release_id, :device_id]
      t.index [:device_id, :release_id]
    end
  end
end
