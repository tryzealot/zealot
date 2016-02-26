class AddSwitcherToPac < ActiveRecord::Migration
  def change
    add_column :pacs, :is_enabled, :int, after: :name, default: 1
    rename_column :pacs, :name, :title
    rename_column :pacs, :content, :script
  end
end
