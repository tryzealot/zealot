# frozen_string_literal: true

class AddDownloadFileTypeToChannel < ActiveRecord::Migration[7.2]
  def change
    add_column :channels, :download_filename_type, :string

    reversible do |dir|
      dir.up do
        # update previous the value of download_filename_type
        Channel.where(download_filename_type: nil).update_all download_filename_type: Channel::DEFAULT_DOWNLOAD_FILENAME_TYPE
      end
    end
  end
end