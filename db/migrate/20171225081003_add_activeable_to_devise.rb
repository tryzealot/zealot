class AddActiveableToDevise < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :activation_token, :string, after: :last_sign_in_ip
    add_column :users, :actived_at, :datetime, after: :activation_token
    add_column :users, :activation_sent_at, :datetime, after: :actived_at

    add_index :users, :activation_token, unique: true

    User.all.update_all actived_at: DateTime.now
  end

  def down
    remove_columns :users, :activation_token, :actived_at, :activation_sent_at
  end
end
