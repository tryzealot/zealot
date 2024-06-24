class CreateVisibilities < ActiveRecord::Migration[7.1]
  def up
    create_table :visibilities do |t|
      t.references :relationable, polymorphic: true
      t.integer :level, default: 0, null: false
      t.string :vault
      t.datetime :expired_at
      t.timestamps
    end

    migrate_channels
  end

  def down
    drop_table :visibilities
  end

  def migrate_channels
    Channel.all.each do |channel|
      if channel.password.blank?
        channel.create_visibility(level: :private)
      else
        channel.create_visibility(level: :password, vault: channel.password)
      end
    end
  end
end
