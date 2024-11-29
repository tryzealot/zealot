# frozen_string_literal: true

class AddDownloadFileTypeToChannel < ActiveRecord::Migration[7.1]
  def up
    # Ensure this incremental update migration is idempotent
    # with monolithic install migration.
    return if connection.column_exists?(:channels, :download_filename_type)

    add_column :channels, :download_filename_type, :string

    Channel.find_each do |channel|
      # 默认值取自 `Channel.DEFAULT_DOWNLOAD_FILENAME_TYPE`
      channel.update!(download_filename_type: 'version_datetime') if channel.download_filename_type.nil?
    end
  end

  def down
    remove_column :channels, :download_filename_type
  end
end
