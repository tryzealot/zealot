class AppendBuildVersionToiOs < ActiveRecord::Migration
  def change
    add_column :ios, :profile, :string, after: :bundle_id
    add_column :ios, :build_version, :string, after: :version
  end
end
