class RemoveUnneededIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :channels, name: "index_channels_on_scheme_id", column: :scheme_id
    remove_index :releases, name: "index_releases_on_channel_id", column: :channel_id
    remove_index :releases, name: "index_releases_on_release_version", column: :release_version
  end
end
