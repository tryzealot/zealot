class AppendCustomFieldsToRelease < ActiveRecord::Migration[6.0]
  def up
    add_column :releases, :custom_fields, :jsonb, null: false, default: []
  end

  def down
    remove_column :releases, :custom_fields
  end
end
