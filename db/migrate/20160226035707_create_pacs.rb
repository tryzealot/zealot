class CreatePacs < ActiveRecord::Migration
  def change
    create_table :pacs do |t|
      t.string :name
      t.string :host
      t.string :port
      t.timestamps null: false
    end
  end
end
