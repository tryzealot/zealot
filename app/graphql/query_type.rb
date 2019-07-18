class QueryType < GraphQL::Schema::Object
  description "The query root of this schema"

  # First describe the field signature:
  field :user, Types::UserType, null: true do
    description 'Find a user by ID'
    argument :id, ID, required: true
  end

  field :app, Types::AppType, null: true do
    description 'Find a app by ID'
    argument :id, ID, required: true
  end

  # Then provide an implementation:
  def user(id:)
    User.find(id)
  end

  def app(id:)
    App.find(id)
  end
end
