# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :username, String, null: true
    field :email, String, null: false do
      def authorize?(obj, args, context)
        current_user = context[:current_user]
        # User can see their own email, admins can see anyone's
        current_user&.admin? || current_user&.id == obj.id
      end
    end
    field :token, String, null: false do
      def authorize?(obj, args, context)
        current_user = context[:current_user]
        # User can see their own token, admins can see anyone's
        current_user&.admin? || current_user&.id == obj.id
      end
    end
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
