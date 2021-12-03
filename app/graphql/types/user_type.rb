# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :username, String, null: true
    field :email, String, null: false
    field :token, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
