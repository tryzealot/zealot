class OptionalReleaseVersionAndBundleId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :releases, :bundle_id, true
    change_column_null :releases, :release_version, true
    change_column_null :releases, :build_version, true
  end
end
