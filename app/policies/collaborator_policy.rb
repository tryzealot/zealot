# frozen_string_literal: true

class CollaboratorPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
