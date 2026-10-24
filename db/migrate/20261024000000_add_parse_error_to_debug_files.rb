class AddParseErrorToDebugFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :debug_files, :parse_error, :string
  end
end
