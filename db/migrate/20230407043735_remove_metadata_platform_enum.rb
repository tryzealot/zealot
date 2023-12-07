class RemoveMetadataPlatformEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP TYPE metadata_platform;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TYPE metadata_platform AS ENUM ('ios', 'android', 'mobileprovision', 'macos');
    SQL
  end
end
