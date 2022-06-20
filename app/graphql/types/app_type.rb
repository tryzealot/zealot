# frozen_string_literal: true

module Types
  class AppType < Types::BaseObject
    description 'App 信息'

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :platform, String, null: false
    field :identifier, String, null: false

    field :version, Int, null: true
    field :release_version, String, null: true
    field :build_version, String, null: true
    field :icon_url, String, null: true
    field :install_url, String, null: true
    field :changelog, String, null: true

    field :key, String, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
