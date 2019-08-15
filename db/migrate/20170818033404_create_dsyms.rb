class CreateDsyms < ActiveRecord::Migration[6.0]
  def change
    create_table :dsyms do |t|
      t.references :app, index: true, foreign_key: { on_delete: :cascade }
      t.string :bundle_id
      t.string :release_version
      t.string :build_version
      t.string :file
      t.string :file_hash
      t.timestamps
    end
  end
end
