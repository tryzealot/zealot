# require_relative 'app_type.rb'
# require_relative 'release_type.rb'

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description '可用的查询: "app(id: x)"'

  field :apps do
    description '查看 App 列表'
    type types[!Types::AppType]

    argument :page, types.Int
    argument :per_page, types.Int
    resolve ->(obj, args, ctx) {
      page = args[:page] || 1
      per_page = args[:per_page] || 20

      App.page(page).per(per_page)
    }
  end

  field :app do
    description '根据 id/slug 查找 App'
    type Types::AppType

    argument :id, types.ID
    argument :slug, types.String
    resolve ->(obj, args, ctx) {
      if args[:id]
        App.find(args[:id])
      elsif args[:slug]
        App.friendly.find(args[:slug])
      end
    }
  end
end
