class CreateJspatches < ActiveRecord::Migration
  def change
    create_table :jspatches do |t|
      t.integer :app_id, null: false
      t.string :title
      t.string :filename
      t.string :min_version
      t.string :max_version
      t.text :script

      t.timestamps null: false
    end

    add_index :jspatches, :app_id
    add_index :jspatches, :filename
  end
end
