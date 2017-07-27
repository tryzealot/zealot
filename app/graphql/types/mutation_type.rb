Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :showApp, Types::AppType do
    argument :id, !types.ID
    resolve ->(_obj, args, _ctx) { App.find(args[:id]) }
  end
end
