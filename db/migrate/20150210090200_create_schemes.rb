class CreateSchemes < ActiveRecord::Migration[6.0]
  def change
    create_table :schemes, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.references :app, index: true, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, index: true
    end
  end
end
