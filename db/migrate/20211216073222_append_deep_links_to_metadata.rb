class AppendDeepLinksToMetadata < ActiveRecord::Migration[6.1]
  def change
    add_column :metadata, :deep_links, :jsonb, null: false, default: []
  end
end
