class CreateIos < ActiveRecord::Migration
  def change
    create_table :ios do |t|
      t.string :name
      t.string :bundle_id
      t.string :version
      t.string :project_path
      t.string :dsym_uuid
      t.string :dsym_file
      t.datetime :packaged_at
      t.timestamps
    end
  end
end
