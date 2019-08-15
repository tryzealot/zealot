class CreateApps < ActiveRecord::Migration[6.0]
  def change
    create_table :apps, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, index: true

      t.timestamps
    end
  end
end
