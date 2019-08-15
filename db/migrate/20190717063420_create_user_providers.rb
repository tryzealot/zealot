class CreateUserProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :user_providers do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :name
      t.string :uid
      t.string :token
      t.integer :expires_at
      t.boolean :expires
      t.string :refresh_token

      t.timestamps
    end

    add_index :user_providers, [:name, :uid]
  end
end
