class CreateJoinTableReleaseDevices < ActiveRecord::Migration[6.0]
  def change
    create_join_table :releases, :devices do |t|
      t.index [:release_id, :device_id]#, unique: true
      t.index [:device_id, :release_id]#, unique: true
    end
  end
end
