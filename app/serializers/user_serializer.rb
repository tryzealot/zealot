# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :id, :username, :email
  attribute :role, if: -> { scope.admin? }
end
