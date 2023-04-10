class ChangeMetadataColumnPlatformToStringType < ActiveRecord::Migration[7.0]
  def change
    change_column :metadata, :platform, :string
  end
end
