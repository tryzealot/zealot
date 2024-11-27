# frozen_string_literal: true

class AddDownloadFileTypeToChannel < ActiveRecord::Migration[7.1]
  def change
    add_column :channels, :download_filename_type, :string, null: true
  end
end
