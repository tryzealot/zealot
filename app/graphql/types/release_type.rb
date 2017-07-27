Types::ReleaseType = GraphQL::ObjectType.define do
  name "Release"
  description "App 的版本列表"

  field :id, !types.Int
  field :version, !types.Int
  field :release_version, !types.String
  field :build_version, !types.String
  field :icon_url, !types.String
  field :download_url, !types.String
  field :changelog, types.String
end
