class AddNativeCodesToMetadata < ActiveRecord::Migration[7.2]
  def change
    add_column :metadata, :native_codes, :jsonb, default: [], null: false
  end
end
