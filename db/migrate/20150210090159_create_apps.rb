class CreateApps < ActiveRecord::Migration[6.0]
  def change
    create_table :apps do |t|
      t.string :name, null: false, index: true
      t.string :description
      t.timestamps
    end
  end
end
