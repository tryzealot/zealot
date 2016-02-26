class AddContentToPac < ActiveRecord::Migration
  def change
    add_column :pacs, :content, :text, after: :port
  end
end
