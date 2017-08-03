Types::AppType = GraphQL::ObjectType.define do
  name "App"
  description "App 信息"

  field :id, !types.Int
  field :slug, !types.String
  field :name, !types.String
  field :platform, !types.String
  field :identifier, !types.String

  field :version, types.Int
  field :release_version, types.String
  field :build_version, types.String
  field :icon_url, types.String
  field :install_url, types.String
  field :changelog, types.String

  field :key, !types.String

  field :created_at, !types.String
  field :updated_at, !types.String
end
