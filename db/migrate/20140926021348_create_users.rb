class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           unique: true
      t.string :email,              null: false, default: '', unique: true
      t.string :encrypted_password, null: false, default: ''
      t.string :token,              null: false, default: '', unique: true
      t.integer :role,              null: false, unique: true

      ## Recoverable
      t.string   :reset_password_token, unique: true
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token, unique: true
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token, unique: true # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.timestamps
    end
  end
end
