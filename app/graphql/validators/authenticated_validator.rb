# frozen_string_literal: true

module GraphQL
  module Validators
    # Validates that a field requires an authenticated user
    # Usage: field :some_field, String, null: false, validates: AuthenticatedValidator
    class AuthenticatedValidator
      def call(field_def, object, arguments, context)
        current_user = context[:current_user]
        return if current_user.present?

        raise GraphQL::ExecutionError, 'Authentication required for this field'
      end
    end

    # Validates that a user has admin role
    class AdminOnlyValidator
      def call(field_def, object, arguments, context)
        current_user = context[:current_user]
        return if current_user&.admin?

        raise GraphQL::ExecutionError, 'Admin access required for this field'
      end
    end
  end
end
