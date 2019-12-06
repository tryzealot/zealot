# frozen_string_literal: true

class ZealotSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
