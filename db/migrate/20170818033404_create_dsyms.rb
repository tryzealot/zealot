class CreateDsyms < ActiveRecord::Migration[5.1]
  def change
    create_table :dsyms do |t|
      t.references :app
      t.string :release_version
      t.string :build_version
      t.string :file
      t.string :file_hash
      t.timestamps
    end
  end
end
