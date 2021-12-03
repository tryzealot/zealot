# frozen_string_literal: true

module Types
  class ReleaseType < Types::BaseObject
    description 'App 的版本列表'

    field :id, ID, null: false
    field :version, Int, null: false
    field :release_version, String, null: false
    field :build_version, String, null: false
    field :icon_url, String, null: false
    field :download_url, String, null: false
    field :changelog, String, null: true
  end
end
