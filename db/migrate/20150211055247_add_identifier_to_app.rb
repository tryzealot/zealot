class AddIdentifierToApp < ActiveRecord::Migration
  def change
    add_column :apps, :identifier, :string, after: :slug

    add_index :apps, :identifier
  end
end
