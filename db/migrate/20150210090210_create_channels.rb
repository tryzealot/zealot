class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.references :scheme, index: true, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: { unique: true }
      t.string :bundle_id, index: true, default: '*'
      t.string :device_type, null: false, index: true
      t.string :git_url, null: true
      t.string :password
      t.string :key, unique: true
    end

    add_index :channels, [:scheme_id, :device_type]
  end
end
