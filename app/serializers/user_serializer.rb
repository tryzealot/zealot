# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :id, :username, :email, :locale, :appearance, :timezone
  attribute :role, if: -> { scope.admin? }
end
