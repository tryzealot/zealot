# frozen_string_literal: true

module GraphqlAuthorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
  end

  def authorize!(action, record)
    policy = Pundit.policy!(current_user, record)

    unless policy.public_send(:"#{action}?")
      raise GraphQL::ExecutionError, "Not authorized to #{action} this resource"
    end
  end

  def current_user
    context[:current_user]
  end
end
