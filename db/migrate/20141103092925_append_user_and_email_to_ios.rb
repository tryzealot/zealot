class AppendUserAndEmailToIos < ActiveRecord::Migration
  def change
    add_column :ios, :username, :string, after: :version
    add_column :ios, :email, :string, after: :username
  end
end
