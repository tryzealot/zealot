class CreateApps < ActiveRecord::Migration[6.0]
  def change
    create_table :apps do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, index: true

      t.timestamps
    end
  end
end
