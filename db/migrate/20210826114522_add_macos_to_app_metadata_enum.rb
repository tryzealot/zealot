class AddMacosToAppMetadataEnum < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TYPE metadata_platform ADD VALUE 'macos';
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'macos'
      AND enumtypid = (
        SELECT oid FROM pg_type WHERE typname = 'metadata_platform'
      );
    SQL
  end
end
