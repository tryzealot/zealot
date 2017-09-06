class CreateDeepLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :deep_links do |t|
      t.string :name
      t.string :category
      t.text :links

      t.timestamps
    end
  end
end
