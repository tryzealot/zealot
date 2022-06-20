# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    description 'The query root of this schema'

    # First describe the field signature:
    field :user, Types::UserType, null: true do
      description 'Find a user by ID'
      argument :id, ID, required: true
    end

    field :app, Types::AppType, null: true do
      description 'Find a app by ID'
      argument :id, ID, required: true
    end

    field :echo, String, null: false do
      description 'Testing endpoint to validate the API with'
      argument :message, String, required: false
    end

    # Then provide an implementation:
    def user(id:)
      User.find(id)
    end

    def app(id:)
      App.find(id)
    end

    def echo(message: nil)
      current_user = context[:current_user]
      message ||= 'hello world'
      "#{current_user.username}说: #{message}"
    end
  end
end
