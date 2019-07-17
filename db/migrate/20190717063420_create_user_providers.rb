class CreateUserProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :user_providers do |t|
      t.string :name
      t.references :user
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
