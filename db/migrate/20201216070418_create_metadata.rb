class CreateMetadata < ActiveRecord::Migration[6.1]
  def change
    create_table :metadata do |t|
      t.references :release, index: true, foreign_key: { on_delete: :cascade }
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :platform, null: false
      t.string :device, null: false
      t.string :name
      t.string :release_version
      t.string :build_version
      t.string :bundle_id
      t.integer :size
      t.string :min_sdk_version
      t.string :target_sdk_version

      # Android
      t.jsonb :activities, null: false, default: []
      t.jsonb :services, null: false, default: []
      t.jsonb :permissions, null: false, default: []
      t.jsonb :features, null: false, default: []

      # iOS
      t.string :release_type
      t.jsonb :mobileprovision, null: false, default: {}
      t.jsonb :developer_certs, null: false, default: []
      t.jsonb :entitlements, null: false, default: {}
      t.jsonb :devices, null: false, default: []
      t.jsonb :capabilities, null: false, default: []
      t.jsonb :url_schemes, null: false, default: []

      t.string :checksum, null: false, index: true
      t.timestamps
    end
  end
end
