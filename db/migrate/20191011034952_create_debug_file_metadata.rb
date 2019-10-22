class CreateDebugFileMetadata < ActiveRecord::Migration[6.0]
  def change
    create_table :debug_file_metadata do |t|
      t.references :debug_file, null: false, foreign_key: true
      t.string  :uuid
      t.string  :type
      t.string  :object
      t.jsonb   :data, null: false, default: {}
      t.integer :size

      t.timestamps
    end
  end
end
