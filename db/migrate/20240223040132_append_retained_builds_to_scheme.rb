class AppendRetainedBuildsToScheme < ActiveRecord::Migration[7.1]
  def change
    add_column :schemes, :retained_builds, :integer, default: 0, null: false
  end
end
