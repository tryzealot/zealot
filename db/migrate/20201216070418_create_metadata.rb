class CreateMetadata < ActiveRecord::Migration[6.0]
  def up
    create_table :metadata do |t|
      t.references :release, index: true, foreign_key: { on_delete: :cascade }
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.string :device, null: false
      t.string :name
      t.string :release_version
      t.string :build_version
      t.string :bundle_id
      t.integer :size
      t.string :min_sdk_version
      t.string :target_sdk_version
      t.jsonb :url_schemes, null: false, default: []

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

      t.string :checksum, null: false, index: true
      t.timestamps
    end

    execute <<-SQL
      CREATE TYPE metadata_platform AS ENUM ('ios', 'android', 'mobileprovision');
    SQL

    add_column :metadata, :platform, :metadata_platform
  end

  def down
    drop_table :metadata

    execute <<-SQL
      DROP TYPE metadata_platform;
    SQL
  end
end
