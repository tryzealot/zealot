class AddUseKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :key, :string, after: :encrypted_password
    add_column :users, :secret, :string, after: :key

    add_index :users, :key, unique: true
  end
end
